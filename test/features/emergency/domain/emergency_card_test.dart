import 'package:flutter_test/flutter_test.dart';
import 'package:my_meds/features/emergency/domain/models/emergency_card_data.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/emergency/domain/services/emergency_card_pdf_service.dart';

void main() {
  group('EmergencyCardData Domain Model', () {
    test('serializes to JSON and deserializes accurately', () {
      final card = EmergencyCardData(
        fullName: 'John Doe',
        bloodType: 'O+',
        allergies: const ['Penicillin', 'Peanuts'],
        chronicConditions: 'Asthma, Mild Hypertension',
        emergencyContacts: const [
          EmergencyContact(
            name: 'Jane Doe',
            phone: '+1-555-0199',
            relationship: 'Spouse',
          ),
          EmergencyContact(
            name: 'Dr. Robert Smith',
            phone: '+1-555-0122',
            relationship: 'Primary Physician',
          ),
        ],
        updatedAt: DateTime(2026, 10, 11),
      );

      final json = card.toJson();
      final restored = EmergencyCardData.fromJson(json);

      expect(restored.fullName, 'John Doe');
      expect(restored.bloodType, 'O+');
      expect(restored.allergies, ['Penicillin', 'Peanuts']);
      expect(restored.chronicConditions, 'Asthma, Mild Hypertension');
      expect(restored.emergencyContacts.length, 2);
      expect(restored.primaryContact?.name, 'Jane Doe');
      expect(restored.primaryContact?.phone, '+1-555-0199');
      expect(restored.primaryContact?.relationship, 'Spouse');
    });

    test('handles empty or missing optional fields gracefully', () {
      final json = <String, dynamic>{
        'fullName': 'Alice Smith',
      };

      final card = EmergencyCardData.fromJson(json);

      expect(card.fullName, 'Alice Smith');
      expect(card.bloodType, isNull);
      expect(card.allergies, isEmpty);
      expect(card.chronicConditions, '');
      expect(card.emergencyContacts, isEmpty);
      expect(card.primaryContact, isNull);
    });

    test('primaryContact returns first contact when available', () {
      const card = EmergencyCardData(
        fullName: 'Bob',
        emergencyContacts: [
          EmergencyContact(name: 'Mom', phone: '123', relationship: 'Mother'),
          EmergencyContact(name: 'Dad', phone: '456', relationship: 'Father'),
        ],
      );

      expect(card.primaryContact?.name, 'Mom');
    });
  });

  group('EmergencyCardPdfService', () {
    test('generates valid non-empty PDF bytes from card and medications', () async {
      const pdfService = EmergencyCardPdfService();

      const card = EmergencyCardData(
        fullName: 'Jane Paramedic Test',
        bloodType: 'A-',
        allergies: ['Latex', 'Aspirin'],
        chronicConditions: 'Severe allergy to bee stings',
        emergencyContacts: [
          EmergencyContact(name: 'Emergency ICE', phone: '911-000', relationship: 'Partner'),
        ],
      );

      final medications = [
        Medication(
          id: 'med_1',
          name: 'Albuterol Inhaler',
          dosage: '90 mcg',
          form: MedicationForm.other,
          quantity: 2,
          expirationDate: DateTime(2028, 5, 1),
          storageConditions: 'Room temperature',
          createdAt: DateTime(2026, 1, 1),
        ),
        Medication(
          id: 'med_2',
          name: 'EpiPen',
          dosage: '0.3 mg',
          form: MedicationForm.injection,
          quantity: 1,
          expirationDate: DateTime(2027, 8, 1),
          notes: 'Keep in emergency pouch',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      final pdfBytes = await pdfService.generatePdf(
        card: card,
        currentMedications: medications,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF documents start with %PDF- header magic bytes
      expect(String.fromCharCodes(pdfBytes.sublist(0, 5)), '%PDF-');
    });
  });
}
