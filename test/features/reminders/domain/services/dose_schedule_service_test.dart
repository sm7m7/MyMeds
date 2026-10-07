import 'package:flutter_test/flutter_test.dart';
import 'package:my_meds/features/reminders/domain/models/dose_log.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';
import 'package:my_meds/features/reminders/domain/services/dose_schedule_service.dart';

void main() {
  const scheduleService = DoseScheduleService();
  final targetDate = DateTime(2026, 10, 7); // Wednesday

  group('DoseScheduleService - Daily Frequency', () {
    test('generates exact daily dose moments for multiple times of day', () {
      final reminder = MedicationReminder(
        id: 'rem-1',
        medicationId: 'med-1',
        medicationName: 'Metformin',
        dosage: '850 mg',
        times: ['08:00', '13:30', '20:00'],
        frequency: ReminderFrequency.daily,
        startDate: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
      );

      final moments = scheduleService.generateDoseTimesForDate(reminder, targetDate);

      expect(moments.length, equals(3));
      expect(moments[0], equals(DateTime(2026, 10, 7, 8, 0)));
      expect(moments[1], equals(DateTime(2026, 10, 7, 13, 30)));
      expect(moments[2], equals(DateTime(2026, 10, 7, 20, 0)));
    });

    test('returns empty list if reminder is inactive', () {
      final reminder = MedicationReminder(
        id: 'rem-1',
        medicationId: 'med-1',
        medicationName: 'Metformin',
        dosage: '850 mg',
        times: ['08:00'],
        frequency: ReminderFrequency.daily,
        startDate: DateTime(2026, 10, 1),
        isActive: false,
        createdAt: DateTime(2026, 10, 1),
      );

      final moments = scheduleService.generateDoseTimesForDate(reminder, targetDate);
      expect(moments, isEmpty);
    });

    test('returns empty list if targetDate is before startDate or after durationDays', () {
      final reminder = MedicationReminder(
        id: 'rem-1',
        medicationId: 'med-1',
        medicationName: 'Amoxicillin',
        dosage: '500 mg',
        times: ['08:00', '20:00'],
        frequency: ReminderFrequency.daily,
        startDate: DateTime(2026, 10, 10), // Starts in future
        durationDays: 7,
        createdAt: DateTime(2026, 10, 1),
      );

      // Before start
      expect(
        scheduleService.generateDoseTimesForDate(reminder, DateTime(2026, 10, 7)),
        isEmpty,
      );

      // During active range
      expect(
        scheduleService.generateDoseTimesForDate(reminder, DateTime(2026, 10, 12)).length,
        equals(2),
      );

      // After end date (10 + 7 = 17)
      expect(
        scheduleService.generateDoseTimesForDate(reminder, DateTime(2026, 10, 20)),
        isEmpty,
      );
    });
  });

  group('DoseScheduleService - Interval Hours Frequency', () {
    test('generates doses spaced by intervalHours across 24h cycle', () {
      final reminder = MedicationReminder(
        id: 'rem-interval',
        medicationId: 'med-2',
        medicationName: 'Painkiller',
        dosage: '200 mg',
        times: ['06:00'],
        frequency: ReminderFrequency.intervalHours,
        intervalHours: 6,
        startDate: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
      );

      final moments = scheduleService.generateDoseTimesForDate(reminder, targetDate);

      expect(moments.length, equals(4)); // 06:00, 12:00, 18:00, 00:00
      expect(moments.map((m) => m.hour), containsAll([0, 6, 12, 18]));
    });
  });

  group('DoseScheduleService - Specific Weekdays Frequency', () {
    test('generates doses only on active weekdays', () {
      // Oct 7, 2026 is Wednesday (weekday = 3)
      // Oct 8, 2026 is Thursday (weekday = 4)
      final reminder = MedicationReminder(
        id: 'rem-weekdays',
        medicationId: 'med-3',
        medicationName: 'Vitamin D',
        dosage: '1000 IU',
        times: ['09:00'],
        frequency: ReminderFrequency.specificWeekdays,
        weekdays: [1, 3, 5], // Mon, Wed, Fri
        startDate: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
      );

      // Wednesday (matches 3)
      final wedMoments = scheduleService.generateDoseTimesForDate(
        reminder,
        DateTime(2026, 10, 7),
      );
      expect(wedMoments.length, equals(1));
      expect(wedMoments.first.hour, equals(9));

      // Thursday (does not match 4)
      final thuMoments = scheduleService.generateDoseTimesForDate(
        reminder,
        DateTime(2026, 10, 8),
      );
      expect(thuMoments, isEmpty);
    });
  });

  group('DoseScheduleService - Today Occurrences & Status Calculation', () {
    test('marks dose Pending if scheduled within grace period or in future', () {
      final now = DateTime(2026, 10, 7, 10, 0); // 10:00 AM

      final reminder = MedicationReminder(
        id: 'rem-1',
        medicationId: 'med-1',
        medicationName: 'Aspirin',
        dosage: '100 mg',
        times: ['14:00'], // In future
        frequency: ReminderFrequency.daily,
        startDate: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
      );

      final occurrences = scheduleService.generateTodayOccurrences(
        reminders: [reminder],
        todayLogs: [],
        now: now,
      );

      expect(occurrences.length, equals(1));
      expect(occurrences.first.computedStatus, equals(DoseLogStatus.pending));
    });

    test('marks unanswered dose Missed if current time exceeds grace period (60 min)', () {
      final now = DateTime(2026, 10, 7, 10, 0); // 10:00 AM

      final reminder = MedicationReminder(
        id: 'rem-1',
        medicationId: 'med-1',
        medicationName: 'Aspirin',
        dosage: '100 mg',
        times: ['08:00'], // 2 hours ago (past 60 min grace period)
        frequency: ReminderFrequency.daily,
        startDate: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
      );

      final occurrences = scheduleService.generateTodayOccurrences(
        reminders: [reminder],
        todayLogs: [],
        now: now,
      );

      expect(occurrences.length, equals(1));
      expect(occurrences.first.computedStatus, equals(DoseLogStatus.missed));
    });

    test('matches recorded DoseLog (Taken/Skipped) regardless of grace period', () {
      final now = DateTime(2026, 10, 7, 10, 0);
      final doseTime = DateTime(2026, 10, 7, 8, 0);

      final reminder = MedicationReminder(
        id: 'rem-1',
        medicationId: 'med-1',
        medicationName: 'Aspirin',
        dosage: '100 mg',
        times: ['08:00'],
        frequency: ReminderFrequency.daily,
        startDate: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
      );

      final log = DoseLog(
        id: 'log-1',
        reminderId: 'rem-1',
        medicationId: 'med-1',
        medicationName: 'Aspirin',
        dosage: '100 mg',
        scheduledTime: doseTime,
        actualTime: DateTime(2026, 10, 7, 8, 5),
        status: DoseLogStatus.taken,
        createdAt: DateTime.now(),
      );

      final occurrences = scheduleService.generateTodayOccurrences(
        reminders: [reminder],
        todayLogs: [log],
        now: now,
      );

      expect(occurrences.length, equals(1));
      expect(occurrences.first.computedStatus, equals(DoseLogStatus.taken));
      expect(occurrences.first.doseLog?.id, equals('log-1'));
    });
  });
}
