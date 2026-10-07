import 'package:my_meds/features/label_reader/domain/models/parsed_medication_label.dart';

/// Contract for AI analysis of OCR text into structured medication fields.
abstract class LabelParserService {
  /// Sends [ocrText] to the AI analysis service and returns structured [ParsedMedicationLabel].
  ///
  /// The AI must return a strict JSON payload:
  /// `{ "name": string|null, "dosage": string|null, "form": string|null, "expirationDate": string|null, "storageConditions": string|null, "confidence": number }`
  /// Missing fields must be null (never guessed).
  Future<ParsedMedicationLabel> parseOcrText(String ocrText);
}
