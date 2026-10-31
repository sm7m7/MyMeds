import 'package:intl/intl.dart';
import 'package:my_meds/features/adherence/domain/models/adherence_models.dart';
import 'package:my_meds/features/reminders/domain/models/dose_log.dart';

/// Pure Dart service computing medication adherence analytics, summaries, and breakdowns.
class AdherenceService {
  const AdherenceService();

  /// Computes overall adherence summary metrics for [logs] within [periodStart] and [periodEnd].
  AdherenceSummary computeSummary({
    required List<DoseLog> logs,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final start = DateTime(periodStart.year, periodStart.month, periodStart.day);
    final end = DateTime(periodEnd.year, periodEnd.month, periodEnd.day, 23, 59, 59, 999);

    final filteredLogs = logs.where((log) {
      final time = log.scheduledTime;
      return !time.isBefore(start) && !time.isAfter(end);
    }).toList();

    int taken = 0;
    int skipped = 0;
    int missed = 0;

    for (final log in filteredLogs) {
      switch (log.status) {
        case DoseLogStatus.taken:
          taken++;
          break;
        case DoseLogStatus.skipped:
          skipped++;
          break;
        case DoseLogStatus.missed:
          missed++;
          break;
        case DoseLogStatus.pending:
          break;
      }
    }

    final int totalScheduled = taken + skipped + missed;
    final double adherenceRate = totalScheduled > 0
        ? ((taken / totalScheduled) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    return AdherenceSummary(
      totalScheduled: totalScheduled,
      totalTaken: taken,
      totalSkipped: skipped,
      totalMissed: missed,
      adherenceRate: adherenceRate,
      periodStart: start,
      periodEnd: end,
    );
  }

  /// Computes day-by-day adherence for the specified [daysCount] ending on [endDate].
  List<DailyAdherence> computeDailyBreakdown({
    required List<DoseLog> logs,
    required DateTime endDate,
    int daysCount = 7,
  }) {
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final List<DailyAdherence> dailyList = [];
    final dayLabelFormat = DateFormat('E'); // "Mon", "Tue"

    for (int i = daysCount - 1; i >= 0; i--) {
      final currentDay = end.subtract(Duration(days: i));
      final dayStart = DateTime(currentDay.year, currentDay.month, currentDay.day);
      final dayEnd = DateTime(currentDay.year, currentDay.month, currentDay.day, 23, 59, 59, 999);

      final dayLogs = logs.where((log) {
        final t = log.scheduledTime;
        return !t.isBefore(dayStart) && !t.isAfter(dayEnd);
      }).toList();

      int taken = 0;
      int skipped = 0;
      int missed = 0;

      for (final log in dayLogs) {
        switch (log.status) {
          case DoseLogStatus.taken:
            taken++;
            break;
          case DoseLogStatus.skipped:
            skipped++;
            break;
          case DoseLogStatus.missed:
            missed++;
            break;
          case DoseLogStatus.pending:
            break;
        }
      }

      final scheduled = taken + skipped + missed;
      final rate = scheduled > 0
          ? ((taken / scheduled) * 100.0).clamp(0.0, 100.0)
          : 0.0;

      dailyList.add(DailyAdherence(
        date: dayStart,
        dayLabel: dayLabelFormat.format(dayStart),
        scheduled: scheduled,
        taken: taken,
        skipped: skipped,
        missed: missed,
        adherenceRate: rate,
      ));
    }

    return dailyList;
  }

  /// Groups [logs] by medication and calculates adherence performance per medication.
  List<MedicationAdherence> computePerMedicationAdherence({
    required List<DoseLog> logs,
  }) {
    final Map<String, List<DoseLog>> grouped = {};

    for (final log in logs) {
      final key = log.medicationId.isNotEmpty
          ? log.medicationId
          : log.medicationName;
      grouped.putIfAbsent(key, () => []).add(log);
    }

    final List<MedicationAdherence> result = [];

    for (final entry in grouped.entries) {
      final medLogs = entry.value;
      if (medLogs.isEmpty) continue;

      final first = medLogs.first;
      int taken = 0;
      int skipped = 0;
      int missed = 0;

      for (final log in medLogs) {
        switch (log.status) {
          case DoseLogStatus.taken:
            taken++;
            break;
          case DoseLogStatus.skipped:
            skipped++;
            break;
          case DoseLogStatus.missed:
            missed++;
            break;
          case DoseLogStatus.pending:
            break;
        }
      }

      final scheduled = taken + skipped + missed;
      final rate = scheduled > 0
          ? ((taken / scheduled) * 100.0).clamp(0.0, 100.0)
          : 0.0;

      result.add(MedicationAdherence(
        medicationId: first.medicationId,
        medicationName: first.medicationName,
        dosage: first.dosage,
        scheduled: scheduled,
        taken: taken,
        skipped: skipped,
        missed: missed,
        adherenceRate: rate,
      ));
    }

    // Sort by scheduled volume and then adherence rate
    result.sort((a, b) {
      final cmp = b.scheduled.compareTo(a.scheduled);
      if (cmp != 0) return cmp;
      return a.adherenceRate.compareTo(b.adherenceRate);
    });

    return result;
  }
}
