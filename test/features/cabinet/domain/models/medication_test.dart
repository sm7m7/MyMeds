import 'package:flutter_test/flutter_test.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_status.dart';

void main() {
  group('Medication Model', () {
    final baseDate = DateTime(2026, 6, 1);

    test('MedicationForm parses strings correctly', () {
      expect(MedicationForm.fromString('tablet'), equals(MedicationForm.tablet));
      expect(MedicationForm.fromString('Capsule'), equals(MedicationForm.capsule));
      expect(MedicationForm.fromString('syrup'), equals(MedicationForm.syrup));
      expect(MedicationForm.fromString('injection'), equals(MedicationForm.injection));
      expect(MedicationForm.fromString('drops'), equals(MedicationForm.drops));
      expect(MedicationForm.fromString('unknown'), equals(MedicationForm.other));
      expect(MedicationForm.fromString(null), equals(MedicationForm.other));
    });

    test('validates input correctly', () {
      expect(
        Medication.validateInput(
          name: 'Amoxicillin',
          dosage: '500 mg',
          quantity: 20,
          expirationDate: DateTime(2027, 1, 1),
        ),
        isNull,
      );

      expect(
        Medication.validateInput(
          name: '   ',
          dosage: '500 mg',
          quantity: 20,
          expirationDate: DateTime(2027, 1, 1),
        ),
        equals('Medication name cannot be empty.'),
      );

      expect(
        Medication.validateInput(
          name: 'Amoxicillin',
          dosage: '',
          quantity: 20,
          expirationDate: DateTime(2027, 1, 1),
        ),
        equals('Dosage cannot be empty.'),
      );

      expect(
        Medication.validateInput(
          name: 'Amoxicillin',
          dosage: '500 mg',
          quantity: -1,
          expirationDate: DateTime(2027, 1, 1),
        ),
        equals('Quantity must be a positive integer or 0.'),
      );

      expect(
        Medication.validateInput(
          name: 'Amoxicillin',
          dosage: '500 mg',
          quantity: 10,
          expirationDate: null,
        ),
        equals('Expiration date is required.'),
      );
    });

    test('correctly calculates status for OK medication', () {
      final med = Medication(
        id: '1',
        name: 'Aspirin',
        dosage: '100 mg',
        form: MedicationForm.tablet,
        quantity: 30,
        expirationDate: baseDate.add(const Duration(days: 90)),
        createdAt: baseDate,
      );

      expect(med.isExpired(baseDate), isFalse);
      expect(med.isExpiringSoon(baseDate), isFalse);
      expect(med.isLowStock, isFalse);
      expect(med.isOk(baseDate), isTrue);
      expect(med.getPrimaryStatus(baseDate), equals(MedicationStatus.ok));
      expect(med.getAllStatuses(baseDate), equals([MedicationStatus.ok]));
    });

    test('correctly calculates status for Expired medication', () {
      final med = Medication(
        id: '2',
        name: 'Paracetamol',
        dosage: '500 mg',
        form: MedicationForm.tablet,
        quantity: 20,
        expirationDate: baseDate.subtract(const Duration(days: 1)),
        createdAt: baseDate.subtract(const Duration(days: 100)),
      );

      expect(med.isExpired(baseDate), isTrue);
      expect(med.getPrimaryStatus(baseDate), equals(MedicationStatus.expired));
      expect(med.getAllStatuses(baseDate), contains(MedicationStatus.expired));
    });

    test('correctly calculates status for Expiring Soon medication', () {
      final med = Medication(
        id: '3',
        name: 'Cough Syrup',
        dosage: '10 ml',
        form: MedicationForm.syrup,
        quantity: 20,
        expirationDate: baseDate.add(const Duration(days: 15)),
        createdAt: baseDate,
      );

      expect(med.isExpired(baseDate), isFalse);
      expect(med.isExpiringSoon(baseDate), isTrue);
      expect(med.getPrimaryStatus(baseDate), equals(MedicationStatus.expiringSoon));
      expect(med.getAllStatuses(baseDate), contains(MedicationStatus.expiringSoon));
    });

    test('correctly calculates status for Low Stock medication', () {
      final med = Medication(
        id: '4',
        name: 'Insulin',
        dosage: '100 U/ml',
        form: MedicationForm.injection,
        quantity: 3, // <= 5
        expirationDate: baseDate.add(const Duration(days: 120)),
        createdAt: baseDate,
      );

      expect(med.isLowStock, isTrue);
      expect(med.getPrimaryStatus(baseDate), equals(MedicationStatus.lowStock));
      expect(med.getAllStatuses(baseDate), contains(MedicationStatus.lowStock));
    });

    test('serializes and deserializes JSON correctly', () {
      final med = Medication(
        id: 'med-99',
        name: 'Ibuprofen',
        dosage: '400 mg',
        form: MedicationForm.capsule,
        quantity: 15,
        expirationDate: DateTime(2027, 5, 20),
        storageConditions: 'Store below 30C',
        notes: 'Take after meals',
        createdAt: DateTime(2026, 1, 15),
      );

      final json = med.toJson();
      final recreated = Medication.fromJson(json, id: 'med-99');

      expect(recreated.id, equals(med.id));
      expect(recreated.name, equals(med.name));
      expect(recreated.dosage, equals(med.dosage));
      expect(recreated.form, equals(med.form));
      expect(recreated.quantity, equals(med.quantity));
      expect(recreated.storageConditions, equals(med.storageConditions));
      expect(recreated.notes, equals(med.notes));
    });
  });
}
