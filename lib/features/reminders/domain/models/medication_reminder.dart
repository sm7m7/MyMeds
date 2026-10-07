import 'package:flutter/foundation.dart';

/// Frequency options for medication reminders.
enum ReminderFrequency {
  daily,
  intervalHours,
  specificWeekdays;

  String get displayName {
    switch (this) {
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.intervalHours:
        return 'Every X Hours';
      case ReminderFrequency.specificWeekdays:
        return 'Specific Weekdays';
    }
  }

  static ReminderFrequency fromString(String? value) {
    if (value == null) return ReminderFrequency.daily;
    return ReminderFrequency.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ReminderFrequency.daily,
    );
  }
}

/// A medication reminder rule configured by the user.
@immutable
class MedicationReminder {
  const MedicationReminder({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.times,
    this.frequency = ReminderFrequency.daily,
    this.intervalHours,
    this.weekdays = const [],
    required this.startDate,
    this.durationDays,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier of the reminder.
  final String id;

  /// Foreign key referencing the cabinet Medication id.
  final String medicationId;

  /// Cached name of medication for offline and notification rendering.
  final String medicationName;

  /// Dosage per intake e.g. "500 mg", "1 tablet".
  final String dosage;

  /// Times of day formatted as "HH:mm" (e.g. ["08:00", "20:00"]).
  final List<String> times;

  /// Frequency pattern.
  final ReminderFrequency frequency;

  /// Interval in hours if [frequency] is [ReminderFrequency.intervalHours].
  final int? intervalHours;

  /// Days of the week (1 = Monday ... 7 = Sunday) if [frequency] is [ReminderFrequency.specificWeekdays].
  final List<int> weekdays;

  /// Date from which the reminder becomes active.
  final DateTime startDate;

  /// Optional duration in days. If null, the reminder repeats indefinitely.
  final int? durationDays;

  /// Whether notifications and scheduling for this reminder are currently active.
  final bool isActive;

  /// Timestamp when created.
  final DateTime createdAt;

  /// Timestamp when last updated.
  final DateTime? updatedAt;

  /// End date of the reminder if durationDays is set.
  DateTime? get endDate {
    if (durationDays == null || durationDays! <= 0) return null;
    return startDate.add(Duration(days: durationDays!));
  }

  /// Whether the reminder is active for a given [date].
  bool isDateInRange(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);

    if (dateOnly.isBefore(startOnly)) return false;

    if (endDate != null) {
      final endOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (dateOnly.isAfter(endOnly)) return false;
    }

    return true;
  }

  /// Human readable frequency description.
  String get frequencyDescription {
    switch (frequency) {
      case ReminderFrequency.daily:
        if (times.isEmpty) return 'Daily';
        if (times.length == 1) return 'Daily at ${times.first}';
        return 'Daily (${times.length} times/day)';
      case ReminderFrequency.intervalHours:
        return 'Every ${intervalHours ?? 8} hours';
      case ReminderFrequency.specificWeekdays:
        if (weekdays.isEmpty) return 'No days selected';
        const dayNames = {
          1: 'Mon',
          2: 'Tue',
          3: 'Wed',
          4: 'Thu',
          5: 'Fri',
          6: 'Sat',
          7: 'Sun',
        };
        final sortedDays = List<int>.from(weekdays)..sort();
        return sortedDays.map((d) => dayNames[d] ?? '').join(', ');
    }
  }

  factory MedicationReminder.fromJson(Map<String, dynamic> json, [String? id]) {
    final timesRaw = json['times'];
    List<String> parsedTimes = [];
    if (timesRaw is List) {
      parsedTimes = timesRaw.map((e) => e.toString()).toList();
    }

    final weekdaysRaw = json['weekdays'];
    List<int> parsedWeekdays = [];
    if (weekdaysRaw is List) {
      parsedWeekdays = weekdaysRaw
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is Map && val['_seconds'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(val['_seconds'] * 1000);
      }
      return DateTime.now();
    }

    return MedicationReminder(
      id: id ?? (json['id'] as String? ?? ''),
      medicationId: json['medicationId'] as String? ?? '',
      medicationName: json['medicationName'] as String? ?? 'Medication',
      dosage: json['dosage'] as String? ?? '1 dose',
      times: parsedTimes,
      frequency: ReminderFrequency.fromString(json['frequency'] as String?),
      intervalHours: json['intervalHours'] as int?,
      weekdays: parsedWeekdays,
      startDate: parseDate(json['startDate']),
      durationDays: json['durationDays'] as int?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'times': times,
      'frequency': frequency.name,
      'intervalHours': intervalHours,
      'weekdays': weekdays,
      'startDate': startDate.toIso8601String(),
      'durationDays': durationDays,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  MedicationReminder copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    String? dosage,
    List<String>? times,
    ReminderFrequency? frequency,
    int? intervalHours,
    List<int>? weekdays,
    DateTime? startDate,
    int? durationDays,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationReminder(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      frequency: frequency ?? this.frequency,
      intervalHours: intervalHours ?? this.intervalHours,
      weekdays: weekdays ?? this.weekdays,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
