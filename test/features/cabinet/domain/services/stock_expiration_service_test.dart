import 'package:flutter_test/flutter_test.dart';
import 'package:my_meds/features/cabinet/domain/models/inventory_settings.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_status.dart';
import 'package:my_meds/features/cabinet/domain/services/stock_expiration_service.dart';

void main() {
  const service = StockExpirationService();
  final fixedNow = DateTime(2026, 10, 7, 12, 0, 0); // October 7, 2026

  Medication createMed({
    String id = 'med-1',
    String name = 'Amoxicillin',
    String dosage = '500 mg',
    MedicationForm form = MedicationForm.capsule,
    int quantity = 20,
    required DateTime expirationDate,
  }) {
    return Medication(
      id: id,
      name: name,
      dosage: dosage,
      form: form,
      quantity: quantity,
      expirationDate: expirationDate,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  group('StockExpirationService - Expiration Date Normalization', () {
    test('parses month-only format MM/YYYY to last day of the month', () {
      // June 2028 has 30 days
      final dateJune = StockExpirationService.parseExpirationDate('06/2028');
      expect(dateJune.year, equals(2028));
      expect(dateJune.month, equals(6));
      expect(dateJune.day, equals(30));

      // December 2026 has 31 days
      final dateDec = StockExpirationService.parseExpirationDate('12/2026');
      expect(dateDec.year, equals(2026));
      expect(dateDec.month, equals(12));
      expect(dateDec.day, equals(31));
    });

    test('accurately computes leap year February 2028 (29 days) vs non-leap 2027 (28 days)', () {
      final leapFeb = StockExpirationService.parseExpirationDate('02/2028');
      expect(leapFeb.year, equals(2028));
      expect(leapFeb.month, equals(2));
      expect(leapFeb.day, equals(29));

      final nonLeapFeb = StockExpirationService.parseExpirationDate('02/2027');
      expect(nonLeapFeb.year, equals(2027));
      expect(nonLeapFeb.month, equals(2));
      expect(nonLeapFeb.day, equals(28));
    });

    test('parses YYYY-MM and short MM/YY formats to end of month', () {
      final ymDate = StockExpirationService.parseExpirationDate('2028-06');
      expect(ymDate.year, equals(2028));
      expect(ymDate.month, equals(6));
      expect(ymDate.day, equals(30));

      final shortDate = StockExpirationService.parseExpirationDate('11/27');
      expect(shortDate.year, equals(2027));
      expect(shortDate.month, equals(11));
      expect(shortDate.day, equals(30));
    });

    test('parses standard full ISO date YYYY-MM-DD correctly', () {
      final isoDate = StockExpirationService.parseExpirationDate('2027-04-15');
      expect(isoDate.year, equals(2027));
      expect(isoDate.month, equals(4));
      expect(isoDate.day, equals(15));
    });
  });

  group('StockExpirationService - Expiration Classification', () {
    test('classifies medication expired when date is strictly before today', () {
      final medExpired = createMed(
        expirationDate: DateTime(2026, 10, 6), // Expired yesterday
      );

      final status = service.classifyMedication(medExpired, now: fixedNow);

      expect(status.isExpired, isTrue);
      expect(status.isExpiringSoon, isFalse);
      expect(status.primaryStatus, equals(MedicationStatus.expired));
      expect(status.attentionNeeded, isTrue);
      expect(status.attentionReason, contains('Expired'));
    });

    test('classifies medication expiring today as expiringSoon (0 days remaining)', () {
      final medToday = createMed(
        expirationDate: DateTime(2026, 10, 7), // Expires today
      );

      final status = service.classifyMedication(medToday, now: fixedNow);

      expect(status.isExpired, isFalse);
      expect(status.isExpiringSoon, isTrue);
      expect(status.daysUntilExpiration, equals(0));
      expect(status.primaryStatus, equals(MedicationStatus.expiringSoon));
      expect(status.attentionReason, contains('Expires today'));
    });

    test('classifies medication expiring within 30 days as expiringSoon', () {
      final medSoon = createMed(
        expirationDate: DateTime(2026, 10, 25), // In 18 days
      );

      final status = service.classifyMedication(medSoon, now: fixedNow);

      expect(status.isExpired, isFalse);
      expect(status.isExpiringSoon, isTrue);
      expect(status.daysUntilExpiration, equals(18));
      expect(status.primaryStatus, equals(MedicationStatus.expiringSoon));
      expect(status.attentionReason, contains('Expires in 18 days'));
    });

    test('classifies medication expiring beyond default 30 days as OK', () {
      final medFar = createMed(
        expirationDate: DateTime(2026, 12, 1), // In 55 days
        quantity: 15,
      );

      final status = service.classifyMedication(medFar, now: fixedNow);

      expect(status.isExpired, isFalse);
      expect(status.isExpiringSoon, isFalse);
      expect(status.isOk, isTrue);
      expect(status.primaryStatus, equals(MedicationStatus.ok));
      expect(status.attentionNeeded, isFalse);
    });

    test('respects custom expiringSoonDaysThreshold in settings', () {
      final med = createMed(
        expirationDate: DateTime(2026, 11, 20), // In 44 days
      );

      // Default (30 days): Not expiring soon
      expect(
        service.classifyMedication(med, now: fixedNow).isExpiringSoon,
        isFalse,
      );

      // Custom (60 days): Expiring soon
      const customSettings = InventorySettings(expiringSoonDaysThreshold: 60);
      expect(
        service
            .classifyMedication(med, now: fixedNow, settings: customSettings)
            .isExpiringSoon,
        isTrue,
      );
    });
  });

  group('StockExpirationService - Stock Classification', () {
    test('flags low stock when quantity is at or below threshold', () {
      final medNormal = createMed(
        quantity: 6,
        expirationDate: DateTime(2027, 1, 1),
      );
      expect(
        service.classifyMedication(medNormal, now: fixedNow).isLowStock,
        isFalse,
      );

      final medBoundary = createMed(
        quantity: 5, // Default threshold = 5
        expirationDate: DateTime(2027, 1, 1),
      );
      final statusBoundary =
          service.classifyMedication(medBoundary, now: fixedNow);
      expect(statusBoundary.isLowStock, isTrue);
      expect(statusBoundary.isOutOfStock, isFalse);
      expect(statusBoundary.primaryStatus, equals(MedicationStatus.lowStock));

      final medZero = createMed(
        quantity: 0,
        expirationDate: DateTime(2027, 1, 1),
      );
      final statusZero = service.classifyMedication(medZero, now: fixedNow);
      expect(statusZero.isLowStock, isTrue);
      expect(statusZero.isOutOfStock, isTrue);
      expect(statusZero.attentionReason, contains('Out of stock'));
    });

    test('respects custom lowStockThreshold in settings', () {
      final med = createMed(
        quantity: 8,
        expirationDate: DateTime(2027, 1, 1),
      );

      // Default threshold (5): OK
      expect(service.classifyMedication(med, now: fixedNow).isLowStock, isFalse);

      // Custom threshold (10): Low Stock
      const customSettings = InventorySettings(lowStockThreshold: 10);
      expect(
        service
            .classifyMedication(med, now: fixedNow, settings: customSettings)
            .isLowStock,
        isTrue,
      );
    });
  });

  group('StockExpirationService - Priority & Multiple Statuses', () {
    test('prioritizes Expired over Low Stock as primary status, but includes both in allStatuses', () {
      final medExpiredAndLow = createMed(
        quantity: 2,
        expirationDate: DateTime(2026, 9, 1), // Expired
      );

      final status =
          service.classifyMedication(medExpiredAndLow, now: fixedNow);

      expect(status.primaryStatus, equals(MedicationStatus.expired));
      expect(status.allStatuses, contains(MedicationStatus.expired));
      expect(status.allStatuses, contains(MedicationStatus.lowStock));
      expect(status.attentionNeeded, isTrue);
    });

    test('prioritizes Expiring Soon over Low Stock as primary status', () {
      final medSoonAndLow = createMed(
        quantity: 3,
        expirationDate: DateTime(2026, 10, 15), // Expiring in 8 days
      );

      final status = service.classifyMedication(medSoonAndLow, now: fixedNow);

      expect(status.primaryStatus, equals(MedicationStatus.expiringSoon));
      expect(status.allStatuses, contains(MedicationStatus.expiringSoon));
      expect(status.allStatuses, contains(MedicationStatus.lowStock));
    });
  });

  group('StockExpirationService - Auto Decrement Quantity', () {
    test('decrements quantity by specified dose units', () {
      final med = createMed(
        quantity: 10,
        expirationDate: DateTime(2027, 1, 1),
      );

      final updated = service.decrementQuantity(med, doseUnits: 1);
      expect(updated.quantity, equals(9));

      final updatedCustom = service.decrementQuantity(med, doseUnits: 3);
      expect(updatedCustom.quantity, equals(7));
    });

    test('clamps decrement to 0 and never becomes negative', () {
      final medOne = createMed(
        quantity: 1,
        expirationDate: DateTime(2027, 1, 1),
      );

      final updatedZero = service.decrementQuantity(medOne, doseUnits: 1);
      expect(updatedZero.quantity, equals(0));

      final updatedClamp = service.decrementQuantity(medOne, doseUnits: 5);
      expect(updatedClamp.quantity, equals(0));
    });
  });

  group('StockExpirationService - Filtering & Alert Notification Generation', () {
    test('filterAttentionNeeded filters correctly', () {
      final med1 = createMed(id: '1', quantity: 20, expirationDate: DateTime(2027, 1, 1)); // OK
      final med2 = createMed(id: '2', quantity: 2, expirationDate: DateTime(2027, 1, 1)); // Low stock
      final med3 = createMed(id: '3', quantity: 20, expirationDate: DateTime(2026, 10, 1)); // Expired

      final list = [med1, med2, med3];
      final attention = service.filterAttentionNeeded(list, now: fixedNow);

      expect(attention.length, equals(2));
      expect(attention.map((m) => m.id), containsAll(['2', '3']));
    });

    test('generates alert notification summary text', () {
      final med1 = createMed(id: '1', quantity: 2, expirationDate: DateTime(2027, 1, 1)); // Low stock
      final med2 = createMed(id: '2', quantity: 20, expirationDate: DateTime(2026, 10, 1)); // Expired
      final med3 = createMed(id: '3', quantity: 20, expirationDate: DateTime(2026, 10, 15)); // Expiring

      final summary = service.generateAlertNotificationBody([med1, med2, med3], now: fixedNow);
      expect(summary, isNotNull);
      expect(summary, contains('1 expired'));
      expect(summary, contains('1 expiring soon'));
      expect(summary, contains('1 low in stock'));
    });

    test('returns null alert notification body when all medications are OK', () {
      final medOk = createMed(quantity: 20, expirationDate: DateTime(2028, 1, 1));
      final summary = service.generateAlertNotificationBody([medOk], now: fixedNow);
      expect(summary, isNull);
    });
  });
}
