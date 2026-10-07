import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';

/// Structured information extracted from medication label OCR and AI analysis.
class ParsedMedicationLabel {
  const ParsedMedicationLabel({
    this.name,
    this.dosage,
    this.form,
    this.expirationDate,
    this.storageConditions,
    this.confidence = 0.0,
    this.rawOcrText = '',
  });

  /// Name of medication (brand or generic). Null if not found on label.
  final String? name;

  /// Dosage / strength (e.g. "500 mg", "10 mg/ml"). Null if not found.
  final String? dosage;

  /// Formulation form (e.g. "tablet", "capsule", "syrup"). Null if not found.
  final String? form;

  /// Expiration date text (e.g. "2027-04", "EXP: 05/2028"). Null if not found.
  final String? expirationDate;

  /// Storage condition instructions (e.g. "Store at 20-25°C"). Null if not found.
  final String? storageConditions;

  /// Extraction confidence score from 0.0 to 1.0.
  final double confidence;

  /// Raw full text output from the OCR engine.
  final String rawOcrText;

  /// Threshold below which a field or overall extraction is considered low confidence.
  static const double lowConfidenceThreshold = 0.70;

  /// Whether the extraction confidence is considered low.
  bool get isLowConfidence => confidence < lowConfidenceThreshold;

  /// Returns true if any essential medical field is missing.
  bool get hasMissingEssentialFields =>
      name == null || name!.trim().isEmpty ||
      dosage == null || dosage!.trim().isEmpty;

  /// Attempts to parse [expirationDate] into a [DateTime] object.
  DateTime? parseExpirationDate() {
    if (expirationDate == null || expirationDate!.trim().isEmpty) return null;
    final clean = expirationDate!.trim();

    // 1. Standard ISO-8601: YYYY-MM-DD or YYYY/MM/DD
    final ymdMatch = RegExp(r'^(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})$').firstMatch(clean);
    if (ymdMatch != null) {
      final year = int.tryParse(ymdMatch.group(1)!) ?? DateTime.now().year;
      final month = int.tryParse(ymdMatch.group(2)!) ?? 1;
      final day = int.tryParse(ymdMatch.group(3)!) ?? 1;
      return DateTime(year, month, day);
    }

    // 2. Year-Month: YYYY-MM or YYYY/MM
    final ymMatch = RegExp(r'^(\d{4})[\/\-](\d{1,2})$').firstMatch(clean);
    if (ymMatch != null) {
      final year = int.tryParse(ymMatch.group(1)!) ?? DateTime.now().year;
      final month = int.tryParse(ymMatch.group(2)!) ?? 1;
      return DateTime(year, month, 28);
    }

    // 3. Month-Year: MM/YYYY or MM-YYYY
    final myMatch = RegExp(r'^(\d{1,2})[\/\-](\d{4})$').firstMatch(clean);
    if (myMatch != null) {
      final month = int.tryParse(myMatch.group(1)!) ?? 1;
      final year = int.tryParse(myMatch.group(2)!) ?? DateTime.now().year;
      return DateTime(year, month, 28);
    }

    // 4. Month-ShortYear: MM/YY or MM-YY
    final shortMyMatch = RegExp(r'^(\d{1,2})[\/\-](\d{2})$').firstMatch(clean);
    if (shortMyMatch != null) {
      final month = int.tryParse(shortMyMatch.group(1)!) ?? 1;
      final year = 2000 + (int.tryParse(shortMyMatch.group(2)!) ?? 26);
      return DateTime(year, month, 28);
    }

    // 5. General DateTime.tryParse
    return DateTime.tryParse(clean);
  }

  /// Converts this parsed label into a cabinet [Medication] ready for persistence.
  Medication toMedication({
    int defaultQuantity = 30,
    String? customNotes,
  }) {
    final parsedExp = parseExpirationDate() ??
        DateTime.now().add(const Duration(days: 180));

    return Medication(
      id: '',
      name: name?.trim().isNotEmpty == true ? name!.trim() : 'Unnamed Medication',
      dosage: dosage?.trim().isNotEmpty == true ? dosage!.trim() : '1 dose',
      form: MedicationForm.fromString(form),
      quantity: defaultQuantity,
      expirationDate: parsedExp,
      storageConditions: storageConditions,
      notes: customNotes ?? (rawOcrText.isNotEmpty ? 'Extracted from label OCR' : null),
      createdAt: DateTime.now(),
    );
  }

  /// Deserializes STRICT JSON returned by the AI parsing service.
  /// Strictly sets missing or unparseable fields to null (never guessed).
  factory ParsedMedicationLabel.fromJson(
    Map<String, dynamic> json, {
    String rawOcrText = '',
  }) {
    String? sanitize(dynamic val) {
      if (val == null) return null;
      final str = val.toString().trim();
      if (str.isEmpty || str.toLowerCase() == 'null' || str.toLowerCase() == 'unknown' || str.toLowerCase() == 'n/a') {
        return null;
      }
      return str;
    }

    double parseConfidence(dynamic val) {
      if (val == null) return 0.5;
      if (val is num) return val.toDouble().clamp(0.0, 1.0);
      if (val is String) {
        final parsed = double.tryParse(val);
        if (parsed != null) return parsed.clamp(0.0, 1.0);
      }
      return 0.5;
    }

    return ParsedMedicationLabel(
      name: sanitize(json['name']),
      dosage: sanitize(json['dosage']),
      form: sanitize(json['form']),
      expirationDate: sanitize(json['expirationDate']),
      storageConditions: sanitize(json['storageConditions']),
      confidence: parseConfidence(json['confidence']),
      rawOcrText: rawOcrText,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'form': form,
      'expirationDate': expirationDate,
      'storageConditions': storageConditions,
      'confidence': confidence,
      'rawOcrText': rawOcrText,
    };
  }

  ParsedMedicationLabel copyWith({
    String? name,
    String? dosage,
    String? form,
    String? expirationDate,
    String? storageConditions,
    double? confidence,
    String? rawOcrText,
  }) {
    return ParsedMedicationLabel(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      expirationDate: expirationDate ?? this.expirationDate,
      storageConditions: storageConditions ?? this.storageConditions,
      confidence: confidence ?? this.confidence,
      rawOcrText: rawOcrText ?? this.rawOcrText,
    );
  }
}
