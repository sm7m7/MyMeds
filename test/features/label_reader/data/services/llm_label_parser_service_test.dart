import 'package:flutter_test/flutter_test.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/label_reader/data/label_reader_exception.dart';
import 'package:my_meds/features/label_reader/data/services/llm_label_parser_service.dart';
import 'package:my_meds/features/label_reader/domain/models/parsed_medication_label.dart';

void main() {
  group('LlmLabelParserService JSON Parsing', () {
    test('parses complete strict JSON payload correctly', () {
      const rawJson = '''
{
  "name": "Advil Liqui-Gels",
  "dosage": "200 mg",
  "form": "capsule",
  "expirationDate": "2027-08",
  "storageConditions": "Store at 20-25C (68-77F)",
  "confidence": 0.95
}
''';

      final result = LlmLabelParserService.parseRawJson(rawJson);

      expect(result.name, equals('Advil Liqui-Gels'));
      expect(result.dosage, equals('200 mg'));
      expect(result.form, equals('capsule'));
      expect(result.expirationDate, equals('2027-08'));
      expect(result.storageConditions, equals('Store at 20-25C (68-77F)'));
      expect(result.confidence, equals(0.95));
      expect(result.isLowConfidence, isFalse);
      expect(result.hasMissingEssentialFields, isFalse);
    });

    test('strictly preserves null for missing or unknown fields without guessing', () {
      const rawJsonWithNulls = '''
{
  "name": "Lisinopril",
  "dosage": "10 mg",
  "form": null,
  "expirationDate": null,
  "storageConditions": "unknown",
  "confidence": 0.65
}
''';

      final result = LlmLabelParserService.parseRawJson(rawJsonWithNulls);

      expect(result.name, equals('Lisinopril'));
      expect(result.dosage, equals('10 mg'));
      expect(result.form, isNull);
      expect(result.expirationDate, isNull);
      expect(result.storageConditions, isNull);
      expect(result.confidence, equals(0.65));
      expect(result.isLowConfidence, isTrue); // < 0.70 threshold
    });

    test('strips markdown code blocks and extracts JSON object from response', () {
      const markdownJson = '''
Here is the extracted medication details:
```json
{
  "name": "Amoxicillin",
  "dosage": "500 mg",
  "form": "tablet",
  "expirationDate": "2026-12-31",
  "storageConditions": "Keep in a dry place",
  "confidence": 0.90
}
```
Hope this helps!
''';

      final result = LlmLabelParserService.parseRawJson(markdownJson);

      expect(result.name, equals('Amoxicillin'));
      expect(result.dosage, equals('500 mg'));
      expect(result.form, equals('tablet'));
      expect(result.expirationDate, equals('2026-12-31'));
      expect(result.confidence, equals(0.90));
    });

    test('throws LabelReaderException on invalid or corrupted JSON', () {
      const corruptedJson = 'This is not a JSON payload at all.';

      expect(
        () => LlmLabelParserService.parseRawJson(corruptedJson),
        throwsA(isA<LabelReaderException>()),
      );
    });
  });

  group('Heuristic Local OCR Parser Fallback', () {
    test('extracts fields from sample OTC bottle OCR text', () {
      const ocrSample1 = '''
ADVIL
Ibuprofen Tablets 200 mg
Pain Reliever / Fever Reducer
100 COATED TABLETS
Store at 20-25°C (68-77°F)
EXP 09/2028
LOT 49302B
''';

      final parsed = LlmLabelParserService.parseLocallyWithHeuristics(ocrSample1);

      expect(parsed.name, contains('ADVIL'));
      expect(parsed.dosage, equals('200 mg'));
      expect(parsed.form, equals('tablet'));
      expect(parsed.expirationDate, equals('09/2028'));
      expect(parsed.storageConditions, contains('Store at 20-25°C'));
      expect(parsed.confidence, greaterThanOrEqualTo(0.7));
    });

    test('extracts fields from sample liquid suspension prescription OCR text', () {
      const ocrSample2 = '''
Rx Only
AMOXICILLIN FOR ORAL SUSPENSION
250 mg / 5 mL
150 mL when reconstituted
Store dry powder below 20°C
Use by: 12/2027
''';

      final parsed = LlmLabelParserService.parseLocallyWithHeuristics(ocrSample2);

      expect(parsed.name, contains('AMOXICILLIN'));
      expect(parsed.dosage, equals('250 mg'));
      expect(parsed.form, equals('syrup'));
      expect(parsed.expirationDate, equals('12/2027'));
    });

    test('extracts fields from ophthalmic drops OCR text', () {
      const ocrSample3 = '''
TOBREX
tobramycin ophthalmic solution
0.3% drops
5 mL Sterile
Store at 2°C to 25°C
EXP: 04/2026
''';

      final parsed = LlmLabelParserService.parseLocallyWithHeuristics(ocrSample3);

      expect(parsed.name, contains('TOBREX'));
      expect(parsed.dosage, equals('0.3%'));
      expect(parsed.form, equals('drops'));
      expect(parsed.expirationDate, equals('04/2026'));
    });
  });

  group('ParsedMedicationLabel Conversion & Date Parsing', () {
    test('parses different expiration date formats correctly', () {
      const labelIso = ParsedMedicationLabel(expirationDate: '2028-05-15');
      expect(labelIso.parseExpirationDate()?.year, equals(2028));
      expect(labelIso.parseExpirationDate()?.month, equals(5));

      const labelSlash = ParsedMedicationLabel(expirationDate: '07/2029');
      expect(labelSlash.parseExpirationDate()?.year, equals(2029));
      expect(labelSlash.parseExpirationDate()?.month, equals(7));

      const labelShort = ParsedMedicationLabel(expirationDate: '11/27');
      expect(labelShort.parseExpirationDate()?.year, equals(2027));
      expect(labelShort.parseExpirationDate()?.month, equals(11));

      const labelNull = ParsedMedicationLabel(expirationDate: null);
      expect(labelNull.parseExpirationDate(), isNull);
    });

    test('toMedication creates valid Medication entity with correct enum mapping', () {
      const label = ParsedMedicationLabel(
        name: 'Motrin',
        dosage: '400 mg',
        form: 'capsule',
        expirationDate: '2027-10',
        storageConditions: 'Store dry',
      );

      final med = label.toMedication(defaultQuantity: 45);

      expect(med.name, equals('Motrin'));
      expect(med.dosage, equals('400 mg'));
      expect(med.form, equals(MedicationForm.capsule));
      expect(med.quantity, equals(45));
      expect(med.storageConditions, equals('Store dry'));
      expect(med.expirationDate.year, equals(2027));
    });
  });
}
