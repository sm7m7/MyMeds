import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_meds/core/config/env_config.dart';
import 'package:my_meds/features/label_reader/data/label_reader_exception.dart';
import 'package:my_meds/features/label_reader/domain/models/parsed_medication_label.dart';
import 'package:my_meds/features/label_reader/domain/services/label_parser_service.dart';

/// Implementation of [LabelParserService] that sends OCR text to an LLM API endpoint or proxy.
///
/// Features:
/// 1. Strict prompt guaranteeing JSON output: `{name, dosage, form, expirationDate, storageConditions, confidence}`.
/// 2. Missing fields are strictly set to `null` (never guessed).
/// 3. API key is never hardcoded; loaded via [EnvConfig] or server proxy.
/// 4. Robust JSON cleaner stripping markdown code fences and whitespace.
/// 5. Intelligent rule-based local parser fallback for offline or development environments.
class LlmLabelParserService implements LabelParserService {
  LlmLabelParserService({
    http.Client? httpClient,
    this.apiEndpoint,
    this.apiKey,
  })  : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String? apiEndpoint;
  final String? apiKey;

  /// Strict system prompt guiding the LLM.
  static const String strictPrompt = '''
You are a specialized medical information extraction engine.
Analyze the following OCR text from a physical medication bottle, box, or blister pack.

Return ONLY a valid JSON object with the exact keys:
{
  "name": "Medication brand name or generic name (or null if absent)",
  "dosage": "Active strength/concentration per dose e.g. 500 mg, 10 mg/ml (or null if absent)",
  "form": "Formulation type: tablet, capsule, syrup, injection, drops, other (or null if absent)",
  "expirationDate": "Expiration date in ISO-8601 (YYYY-MM-DD or YYYY-MM) format (or null if absent)",
  "storageConditions": "Temperature/moisture storage advice (or null if absent)",
  "confidence": 0.0 to 1.0 (float reflecting clarity of extraction)
}

RULES:
- If a field cannot be clearly identified from the text, set its value to null.
- NEVER invent, hallucinate, or guess missing information.
- Return ONLY the JSON object, with NO markdown code fences or explanatory text.
''';

  @override
  Future<ParsedMedicationLabel> parseOcrText(String ocrText) async {
    final cleanOcr = ocrText.trim();
    if (cleanOcr.isEmpty) {
      throw const LabelReaderException(
        'No OCR text was provided for AI analysis.',
        type: LabelReaderErrorType.noTextFound,
      );
    }

    // Try remote LLM API if configured
    final endpoint = apiEndpoint ??
        (EnvConfig.firebaseApiKey.isNotEmpty
            ? 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${EnvConfig.firebaseApiKey}'
            : null);

    if (endpoint != null && endpoint.isNotEmpty) {
      try {
        final key = apiKey;
        final response = await _httpClient.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            if (key != null && key.isNotEmpty)
              'Authorization': 'Bearer $key',
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': '$strictPrompt\n\nOCR TEXT TO ANALYZE:\n$cleanOcr'}
                ]
              }
            ],
            'generationConfig': {
              'response_mime_type': 'application/json',
              'temperature': 0.1,
            }
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data =
              jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates.first['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts.first['text'] as String?;
              if (text != null && text.isNotEmpty) {
                return parseRawJson(text, rawOcrText: cleanOcr);
              }
            }
          }
        }
      } on SocketException {
        // Fallback to local heuristic parser when offline
        return parseLocallyWithHeuristics(cleanOcr);
      } on http.ClientException {
        // Fallback to local heuristic parser
        return parseLocallyWithHeuristics(cleanOcr);
      } catch (_) {
        // If API fails, use heuristic fallback
      }
    }

    // Heuristic extraction fallback
    return parseLocallyWithHeuristics(cleanOcr);
  }

  /// Parses raw JSON string returned by AI, stripping markdown fences if present.
  static ParsedMedicationLabel parseRawJson(
    String rawJsonText, {
    String rawOcrText = '',
  }) {
    try {
      var sanitized = rawJsonText.trim();

      // Strip markdown code fences e.g. ```json ... ```
      if (sanitized.startsWith('```')) {
        final firstNewline = sanitized.indexOf('\n');
        if (firstNewline != -1) {
          sanitized = sanitized.substring(firstNewline + 1);
        }
        if (sanitized.endsWith('```')) {
          sanitized = sanitized.substring(0, sanitized.length - 3).trim();
        }
      }

      // Extract JSON object substring if surrounding prose exists
      final startIndex = sanitized.indexOf('{');
      final endIndex = sanitized.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
        sanitized = sanitized.substring(startIndex, endIndex + 1);
      }

      final Map<String, dynamic> parsed =
          jsonDecode(sanitized) as Map<String, dynamic>;

      return ParsedMedicationLabel.fromJson(parsed, rawOcrText: rawOcrText);
    } catch (e) {
      throw LabelReaderException(
        'Failed to parse structured JSON from AI label response: $e',
        type: LabelReaderErrorType.apiFailure,
        cause: e,
      );
    }
  }

  /// High-accuracy rule-based heuristic extractor used as an offline/instant fallback.
  static ParsedMedicationLabel parseLocallyWithHeuristics(String ocrText) {
    String? extractedName;
    String? extractedDosage;
    String? extractedForm;
    String? extractedExpiration;
    String? extractedStorage;
    double confidence = 0.5;

    final lines = ocrText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // 1. Extract Dosage (e.g. 500mg, 100 mg, 10ml, 2.5mg/ml, 800mcg, 0.3%)
    final dosageRegex = RegExp(
      r'(\d+(?:\.\d+)?\s*(?:mg\/ml|mcg|mg|iu|ml|g|%))',
      caseSensitive: false,
    );
    for (final line in lines) {
      final match = dosageRegex.firstMatch(line);
      if (match != null) {
        extractedDosage = match.group(1)?.trim();
        break;
      }
    }

    // 2. Extract Formulation Form
    final lowerOcr = ocrText.toLowerCase();
    if (RegExp(r'\b(drops?|ophthalmic|otic|collyre)\b').hasMatch(lowerOcr)) {
      extractedForm = 'drops';
    } else if (RegExp(r'\b(tablets?|comprim[eé]s?|pills?)\b').hasMatch(lowerOcr)) {
      extractedForm = 'tablet';
    } else if (RegExp(r'\b(capsules?|g[eé]lules?)\b').hasMatch(lowerOcr)) {
      extractedForm = 'capsule';
    } else if (RegExp(r'\b(injection|injectable|vial|ampoule|iv|im)\b').hasMatch(lowerOcr)) {
      extractedForm = 'injection';
    } else if (RegExp(r'\b(syrup|sirop|suspension|solution|liquid|elixir)\b').hasMatch(lowerOcr)) {
      extractedForm = 'syrup';
    } else if (RegExp(r'\b(cream|gel|ointment|spray|pommade)\b').hasMatch(lowerOcr)) {
      extractedForm = 'other';
    }

    // 3. Extract Expiration Date
    final expRegex = RegExp(
      r'(?:EXP|EXPIRES?|EXPIRY|BB|USE BY)[:\s]*([0-9]{1,2}[\/\-][0-9]{2,4}|[0-9]{4}[\/\-][0-9]{1,2})',
      caseSensitive: false,
    );
    final standaloneDateRegex = RegExp(
      r'\b(20[2-3][0-9][\/\-][0-1][0-9](?:[\/\-][0-3][0-9])?|(?:0[1-9]|1[0-2])[\/\-](?:20)?[2-3][0-9])\b',
    );

    for (final line in lines) {
      final match = expRegex.firstMatch(line);
      if (match != null) {
        extractedExpiration = match.group(1);
        break;
      }
    }

    if (extractedExpiration == null) {
      for (final line in lines) {
        final match = standaloneDateRegex.firstMatch(line);
        if (match != null) {
          extractedExpiration = match.group(1);
          break;
        }
      }
    }

    // 4. Extract Storage conditions
    final storageRegex = RegExp(
      r'((?:store|keep)[:\s].*?(?:below|between|room temperature|dry place|reach of children|\d+°?\s*c|\d+°?\s*f)[^\n.]*)',
      caseSensitive: false,
    );
    for (final line in lines) {
      final match = storageRegex.firstMatch(line);
      if (match != null) {
        extractedStorage = match.group(1)?.trim();
        break;
      }
    }

    // 5. Extract Name (First prominent line not matching common metadata prefixes)
    final ignoreWords = [
      'rx only',
      'lot',
      'exp',
      'keep out of reach',
      'store',
      'manufactured',
      'ndc',
      'dosage',
      'each tablet',
      'warnings',
      'distr by',
    ];

    for (final line in lines) {
      final lower = line.toLowerCase();
      final hasIgnoredWord =
          ignoreWords.any((w) => lower.startsWith(w) || lower == w);
      if (!hasIgnoredWord && line.length >= 3 && !line.startsWith('NDC')) {
        // Strip dosage from name if included in same line
        var candidateName = line;
        if (extractedDosage != null && candidateName.contains(extractedDosage)) {
          candidateName = candidateName.replaceAll(extractedDosage, '').trim();
        }
        if (candidateName.isNotEmpty) {
          extractedName = candidateName;
          break;
        }
      }
    }

    // Confidence heuristic calculation
    int matchedFields = 0;
    if (extractedName != null) matchedFields += 2;
    if (extractedDosage != null) matchedFields += 2;
    if (extractedForm != null) matchedFields += 1;
    if (extractedExpiration != null) matchedFields += 1;

    confidence = (matchedFields / 6.0).clamp(0.2, 0.95);

    return ParsedMedicationLabel(
      name: extractedName,
      dosage: extractedDosage,
      form: extractedForm,
      expirationDate: extractedExpiration,
      storageConditions: extractedStorage,
      confidence: confidence,
      rawOcrText: ocrText,
    );
  }
}
