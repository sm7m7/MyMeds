import 'package:flutter_test/flutter_test.dart';
import 'package:my_meds/features/adherence/domain/services/adherence_service.dart';
import 'package:my_meds/features/reminders/domain/models/dose_log.dart';

// Helper: builds a DoseLog with sensible defaults.
DoseLog _log({
  required String id,
  required String medicationId,
  required String medicationName,
  required DateTime scheduledTime,
  required DoseLogStatus status,
  String dosage = '1 dose',
  String reminderId = 'rem_1',
  DateTime? actualTime,
  DateTime? createdAt,
}) {
  return DoseLog(
    id: id,
    reminderId: reminderId,
    medicationId: medicationId,
    medicationName: medicationName,
    dosage: dosage,
    scheduledTime: scheduledTime,
    actualTime: actualTime,
    status: status,
    createdAt: createdAt ?? DateTime.now(),
  );
}

void main() {
  const service = AdherenceService();
  final now = DateTime(2026, 10, 7, 12, 0);

  // ─────────────────────────────────────────────────────────────────────────
  // computeSummary
  // ─────────────────────────────────────────────────────────────────────────
  group('AdherenceService - computeSummary', () {
    test('computes adherence rate 86% for 21 scheduled, 18 taken, 3 missed',
        () {
      final logs = <DoseLog>[
        // 18 taken
        ...List.generate(
          18,
          (i) => _log(
            id: 'log_taken_$i',
            medicationId: 'med_1',
            medicationName: 'Amoxicillin',
            dosage: '500mg',
            scheduledTime: now.subtract(Duration(hours: i * 3)),
            status: DoseLogStatus.taken,
            actualTime: now.subtract(Duration(hours: i * 3)),
          ),
        ),
        // 3 missed
        ...List.generate(
          3,
          (i) => _log(
            id: 'log_missed_$i',
            medicationId: 'med_1',
            medicationName: 'Amoxicillin',
            dosage: '500mg',
            scheduledTime: now.subtract(Duration(hours: (i + 18) * 3)),
            status: DoseLogStatus.missed,
          ),
        ),
      ];

      final summary = service.computeSummary(
        logs: logs,
        periodStart: now.subtract(const Duration(days: 7)),
        periodEnd: now,
      );

      expect(summary.totalScheduled, 21);
      expect(summary.totalTaken, 18);
      expect(summary.totalMissed, 3);
      expect(summary.totalSkipped, 0);
      expect(summary.adherenceRate, closeTo(85.714, 0.01));
      expect(summary.formattedRate, '86%');
      expect(summary.hasData, isTrue);
    });

    test('computes 100% adherence when all doses are taken', () {
      final logs = List.generate(
        10,
        (i) => _log(
          id: 'log_$i',
          medicationId: 'med_1',
          medicationName: 'Paracetamol',
          dosage: '1000mg',
          scheduledTime: now.subtract(Duration(hours: i * 2)),
          status: DoseLogStatus.taken,
        ),
      );

      final summary = service.computeSummary(
        logs: logs,
        periodStart: now.subtract(const Duration(days: 7)),
        periodEnd: now,
      );

      expect(summary.totalScheduled, 10);
      expect(summary.totalTaken, 10);
      expect(summary.totalMissed, 0);
      expect(summary.adherenceRate, 100.0);
      expect(summary.formattedRate, '100%');
    });

    test('computes 0% adherence when all doses are missed', () {
      final logs = List.generate(
        5,
        (i) => _log(
          id: 'log_$i',
          medicationId: 'med_1',
          medicationName: 'Ibuprofen',
          dosage: '400mg',
          scheduledTime: now.subtract(Duration(hours: i * 4)),
          status: DoseLogStatus.missed,
        ),
      );

      final summary = service.computeSummary(
        logs: logs,
        periodStart: now.subtract(const Duration(days: 7)),
        periodEnd: now,
      );

      expect(summary.totalScheduled, 5);
      expect(summary.totalTaken, 0);
      expect(summary.totalMissed, 5);
      expect(summary.adherenceRate, 0.0);
      expect(summary.formattedRate, '0%');
    });

    test('handles empty logs gracefully with 0 scheduled and 0% rate', () {
      final summary = service.computeSummary(
        logs: [],
        periodStart: now.subtract(const Duration(days: 7)),
        periodEnd: now,
      );

      expect(summary.totalScheduled, 0);
      expect(summary.totalTaken, 0);
      expect(summary.totalMissed, 0);
      expect(summary.totalSkipped, 0);
      expect(summary.adherenceRate, 0.0);
      expect(summary.hasData, isFalse);
    });

    test('ignores pending logs and logs outside the date range', () {
      final logs = [
        // Within range - taken
        _log(
          id: 'log_in_1',
          medicationId: 'med_1',
          medicationName: 'Lisinopril',
          dosage: '10mg',
          scheduledTime: now.subtract(const Duration(days: 2)),
          status: DoseLogStatus.taken,
        ),
        // Within range - pending (should not count towards totalScheduled)
        _log(
          id: 'log_in_2',
          medicationId: 'med_1',
          medicationName: 'Lisinopril',
          dosage: '10mg',
          scheduledTime: now.subtract(const Duration(hours: 1)),
          status: DoseLogStatus.pending,
        ),
        // Outside range (10 days ago) - missed
        _log(
          id: 'log_out_1',
          medicationId: 'med_1',
          medicationName: 'Lisinopril',
          dosage: '10mg',
          scheduledTime: now.subtract(const Duration(days: 10)),
          status: DoseLogStatus.missed,
        ),
      ];

      final summary = service.computeSummary(
        logs: logs,
        periodStart: now.subtract(const Duration(days: 7)),
        periodEnd: now,
      );

      expect(summary.totalScheduled, 1);
      expect(summary.totalTaken, 1);
      expect(summary.totalMissed, 0);
      expect(summary.adherenceRate, 100.0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // computeDailyBreakdown
  // ─────────────────────────────────────────────────────────────────────────
  group('AdherenceService - computeDailyBreakdown', () {
    test(
        'returns exact number of requested days with populated labels and dates',
        () {
      final logs = [
        _log(
          id: 'log_1',
          medicationId: 'med_1',
          medicationName: 'Metformin',
          dosage: '500mg',
          scheduledTime: now,
          status: DoseLogStatus.taken,
        ),
        _log(
          id: 'log_2',
          medicationId: 'med_1',
          medicationName: 'Metformin',
          dosage: '500mg',
          scheduledTime: now,
          status: DoseLogStatus.missed,
        ),
        _log(
          id: 'log_3',
          medicationId: 'med_1',
          medicationName: 'Metformin',
          dosage: '500mg',
          scheduledTime: now.subtract(const Duration(days: 1)),
          status: DoseLogStatus.skipped,
        ),
      ];

      final breakdown = service.computeDailyBreakdown(
        logs: logs,
        endDate: now,
        daysCount: 7,
      );

      expect(breakdown.length, 7);

      // Today (last item)
      final today = breakdown.last;
      expect(today.scheduled, 2);
      expect(today.taken, 1);
      expect(today.missed, 1);
      expect(today.skipped, 0);
      expect(today.adherenceRate, 50.0);

      // Yesterday (second to last item)
      final yesterday = breakdown[breakdown.length - 2];
      expect(yesterday.scheduled, 1);
      expect(yesterday.taken, 0);
      expect(yesterday.skipped, 1);
      expect(yesterday.adherenceRate, 0.0);

      // Other days (empty)
      final day3 = breakdown[0];
      expect(day3.scheduled, 0);
      expect(day3.taken, 0);
      expect(day3.adherenceRate, 0.0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // computePerMedicationAdherence
  // ─────────────────────────────────────────────────────────────────────────
  group('AdherenceService - computePerMedicationAdherence', () {
    test('groups logs by medication and calculates rates correctly', () {
      final logs = [
        // Med A: 2 taken, 0 missed -> 100%
        _log(
          id: '1',
          medicationId: 'med_a',
          medicationName: 'Aspirin',
          dosage: '81mg',
          scheduledTime: now,
          status: DoseLogStatus.taken,
        ),
        _log(
          id: '2',
          medicationId: 'med_a',
          medicationName: 'Aspirin',
          dosage: '81mg',
          scheduledTime: now.subtract(const Duration(days: 1)),
          status: DoseLogStatus.taken,
        ),
        // Med B: 1 taken, 3 missed -> 25% (4 total scheduled)
        _log(
          id: '3',
          medicationId: 'med_b',
          medicationName: 'Atorvastatin',
          dosage: '20mg',
          scheduledTime: now,
          status: DoseLogStatus.taken,
        ),
        _log(
          id: '4',
          medicationId: 'med_b',
          medicationName: 'Atorvastatin',
          dosage: '20mg',
          scheduledTime: now.subtract(const Duration(days: 1)),
          status: DoseLogStatus.missed,
        ),
        _log(
          id: '5',
          medicationId: 'med_b',
          medicationName: 'Atorvastatin',
          dosage: '20mg',
          scheduledTime: now.subtract(const Duration(days: 2)),
          status: DoseLogStatus.missed,
        ),
        _log(
          id: '6',
          medicationId: 'med_b',
          medicationName: 'Atorvastatin',
          dosage: '20mg',
          scheduledTime: now.subtract(const Duration(days: 3)),
          status: DoseLogStatus.missed,
        ),
      ];

      final results = service.computePerMedicationAdherence(logs: logs);

      expect(results.length, 2);

      // Sorted by scheduled volume descending (Atorvastatin had 4, Aspirin had 2)
      final first = results[0];
      expect(first.medicationName, 'Atorvastatin');
      expect(first.scheduled, 4);
      expect(first.taken, 1);
      expect(first.missed, 3);
      expect(first.adherenceRate, 25.0);
      expect(first.formattedRate, '25%');

      final second = results[1];
      expect(second.medicationName, 'Aspirin');
      expect(second.scheduled, 2);
      expect(second.taken, 2);
      expect(second.missed, 0);
      expect(second.adherenceRate, 100.0);
      expect(second.formattedRate, '100%');
    });

    test('returns empty list when logs are empty', () {
      final results = service.computePerMedicationAdherence(logs: []);
      expect(results, isEmpty);
    });
  });
}
