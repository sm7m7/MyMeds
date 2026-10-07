import 'package:my_meds/features/reminders/domain/models/dose_log.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';

/// Service responsible for calculating scheduled dose occurrences, frequencies, and status.
class DoseScheduleService {
  const DoseScheduleService();

  /// Default grace period after which an unanswered scheduled dose is considered Missed.
  static const Duration defaultGracePeriod = Duration(minutes: 60);

  /// Generates the list of scheduled [DateTime] moments for a specific [reminder] on [date].
  List<DateTime> generateDoseTimesForDate(MedicationReminder reminder, DateTime date) {
    if (!reminder.isActive) return const [];
    if (!reminder.isDateInRange(date)) return const [];

    final targetDate = DateTime(date.year, date.month, date.day);

    switch (reminder.frequency) {
      case ReminderFrequency.daily:
        return _generateDailyTimes(reminder.times, targetDate);

      case ReminderFrequency.intervalHours:
        return _generateIntervalTimes(
          reminder.times,
          reminder.intervalHours ?? 8,
          targetDate,
        );

      case ReminderFrequency.specificWeekdays:
        if (!reminder.weekdays.contains(targetDate.weekday)) {
          return const [];
        }
        return _generateDailyTimes(reminder.times, targetDate);
    }
  }

  /// Parses a "HH:mm" string into a [DateTime] on [targetDate].
  DateTime? parseTimeString(String timeStr, DateTime targetDate) {
    final parts = timeStr.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
  }

  List<DateTime> _generateDailyTimes(List<String> times, DateTime targetDate) {
    if (times.isEmpty) return const [];
    final List<DateTime> result = [];

    for (final t in times) {
      final parsed = parseTimeString(t, targetDate);
      if (parsed != null) {
        result.add(parsed);
      }
    }

    result.sort();
    return result;
  }

  List<DateTime> _generateIntervalTimes(
    List<String> times,
    int intervalHours,
    DateTime targetDate,
  ) {
    if (intervalHours <= 0 || intervalHours > 24) return const [];

    // Starting reference hour
    int startHour = 8;
    int startMinute = 0;
    if (times.isNotEmpty) {
      final parsed = parseTimeString(times.first, targetDate);
      if (parsed != null) {
        startHour = parsed.hour;
        startMinute = parsed.minute;
      }
    }

    final List<DateTime> result = [];
    int currentHour = startHour;

    // Generate times for the full 24h cycle
    while (currentHour < 24) {
      result.add(DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        currentHour,
        startMinute,
      ));
      currentHour += intervalHours;
    }

    // Wrap around if starting later in the day, but anchor on this target date
    if (startHour >= intervalHours) {
      int prevHour = startHour - intervalHours;
      while (prevHour >= 0) {
        result.add(DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          prevHour,
          startMinute,
        ));
        prevHour -= intervalHours;
      }
    }

    result.sort();
    return result;
  }

  /// Combines active reminders with recorded dose logs to build a timeline of today's doses.
  List<DoseOccurrence> generateTodayOccurrences({
    required List<MedicationReminder> reminders,
    required List<DoseLog> todayLogs,
    required DateTime now,
    Duration gracePeriod = defaultGracePeriod,
  }) {
    final List<DoseOccurrence> occurrences = [];
    final today = DateTime(now.year, now.month, now.day);

    for (final reminder in reminders) {
      if (!reminder.isActive) continue;

      final scheduledMoments = generateDoseTimesForDate(reminder, today);

      for (final scheduled in scheduledMoments) {
        // Find matching log for this reminder and dose time
        final matchedLog = _findMatchingLog(todayLogs, reminder.id, scheduled);

        final DoseLogStatus status;
        if (matchedLog != null) {
          status = matchedLog.status;
        } else {
          // Check if dose has expired past the grace period
          final cutoffTime = scheduled.add(gracePeriod);
          if (now.isAfter(cutoffTime)) {
            status = DoseLogStatus.missed;
          } else {
            status = DoseLogStatus.pending;
          }
        }

        occurrences.add(DoseOccurrence(
          reminder: reminder,
          scheduledTime: scheduled,
          doseLog: matchedLog,
          computedStatus: status,
        ));
      }
    }

    occurrences.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return occurrences;
  }

  DoseLog? _findMatchingLog(
    List<DoseLog> logs,
    String reminderId,
    DateTime scheduledTime,
  ) {
    for (final log in logs) {
      if (log.reminderId == reminderId) {
        // Match within a 5-minute threshold to account for minor clock discrepancies
        final diff = log.scheduledTime.difference(scheduledTime).inMinutes.abs();
        if (diff <= 5) {
          return log;
        }
      }
    }
    return null;
  }
}
