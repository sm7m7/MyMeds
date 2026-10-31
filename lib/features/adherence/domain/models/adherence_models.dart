import 'package:flutter/foundation.dart';

/// Time period filter for adherence analytics.
enum AdherencePeriod {
  week,
  month;

  String get displayName {
    switch (this) {
      case AdherencePeriod.week:
        return 'Last 7 Days';
      case AdherencePeriod.month:
        return 'Last 30 Days';
    }
  }

  int get days {
    switch (this) {
      case AdherencePeriod.week:
        return 7;
      case AdherencePeriod.month:
        return 30;
    }
  }
}

/// Overall adherence summary metrics for a specified period.
@immutable
class AdherenceSummary {
  const AdherenceSummary({
    required this.totalScheduled,
    required this.totalTaken,
    required this.totalSkipped,
    required this.totalMissed,
    required this.adherenceRate,
    required this.periodStart,
    required this.periodEnd,
  });

  final int totalScheduled;
  final int totalTaken;
  final int totalSkipped;
  final int totalMissed;

  /// Adherence percentage between 0.0 and 100.0.
  final double adherenceRate;

  final DateTime periodStart;
  final DateTime periodEnd;

  /// Formatted percentage string (e.g. "86%").
  String get formattedRate => '${adherenceRate.round()}%';

  /// Whether there were any scheduled doses in this period.
  bool get hasData => totalScheduled > 0;
}

/// Adherence metrics for a single calendar day.
@immutable
class DailyAdherence {
  const DailyAdherence({
    required this.date,
    required this.dayLabel,
    required this.scheduled,
    required this.taken,
    required this.skipped,
    required this.missed,
    required this.adherenceRate,
  });

  final DateTime date;
  final String dayLabel; // e.g. "Mon", "Tue"
  final int scheduled;
  final int taken;
  final int skipped;
  final int missed;
  final double adherenceRate;
}

/// Adherence metrics broken down by individual medication.
@immutable
class MedicationAdherence {
  const MedicationAdherence({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.scheduled,
    required this.taken,
    required this.skipped,
    required this.missed,
    required this.adherenceRate,
  });

  final String medicationId;
  final String medicationName;
  final String dosage;
  final int scheduled;
  final int taken;
  final int skipped;
  final int missed;
  final double adherenceRate;

  String get formattedRate => '${adherenceRate.round()}%';
}
