import 'package:flutter/foundation.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';

/// Status of a scheduled medication dose.
enum DoseLogStatus {
  pending,
  taken,
  skipped,
  missed;

  String get displayName {
    switch (this) {
      case DoseLogStatus.pending:
        return 'Pending';
      case DoseLogStatus.taken:
        return 'Taken';
      case DoseLogStatus.skipped:
        return 'Skipped';
      case DoseLogStatus.missed:
        return 'Missed';
    }
  }

  static DoseLogStatus fromString(String? value) {
    if (value == null) return DoseLogStatus.pending;
    return DoseLogStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DoseLogStatus.pending,
    );
  }
}

/// A recorded dose event in Firestore at `users/{uid}/doseLogs/{id}`.
@immutable
class DoseLog {
  const DoseLog({
    required this.id,
    required this.reminderId,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    this.actualTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  /// Unique identifier of the dose log.
  final String id;

  /// Reference to the reminder rule that generated this dose.
  final String reminderId;

  /// Reference to the cabinet medication.
  final String medicationId;

  /// Cached medication name.
  final String medicationName;

  /// Dosage taken e.g. "500 mg".
  final String dosage;

  /// Exact scheduled time of intake.
  final DateTime scheduledTime;

  /// Actual timestamp when the user marked Taken or Skipped.
  final DateTime? actualTime;

  /// Recorded status: taken, skipped, or missed.
  final DoseLogStatus status;

  /// Optional user notes.
  final String? notes;

  /// Timestamp when recorded in Firestore.
  final DateTime createdAt;

  factory DoseLog.fromJson(Map<String, dynamic> json, [String? id]) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is Map && val['_seconds'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(val['_seconds'] * 1000);
      }
      return DateTime.now();
    }

    return DoseLog(
      id: id ?? (json['id'] as String? ?? ''),
      reminderId: json['reminderId'] as String? ?? '',
      medicationId: json['medicationId'] as String? ?? '',
      medicationName: json['medicationName'] as String? ?? 'Medication',
      dosage: json['dosage'] as String? ?? '1 dose',
      scheduledTime: parseDate(json['scheduledTime']),
      actualTime: json['actualTime'] != null ? parseDate(json['actualTime']) : null,
      status: DoseLogStatus.fromString(json['status'] as String?),
      notes: json['notes'] as String?,
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderId': reminderId,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'scheduledTime': scheduledTime.toIso8601String(),
      'actualTime': actualTime?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  DoseLog copyWith({
    String? id,
    String? reminderId,
    String? medicationId,
    String? medicationName,
    String? dosage,
    DateTime? scheduledTime,
    DateTime? actualTime,
    DoseLogStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return DoseLog(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// View model representing an occurrence of a medication dose on a specific date/time.
@immutable
class DoseOccurrence {
  const DoseOccurrence({
    required this.reminder,
    required this.scheduledTime,
    this.doseLog,
    required this.computedStatus,
  });

  final MedicationReminder reminder;
  final DateTime scheduledTime;
  final DoseLog? doseLog;
  final DoseLogStatus computedStatus;

  bool get isTaken => computedStatus == DoseLogStatus.taken;
  bool get isSkipped => computedStatus == DoseLogStatus.skipped;
  bool get isMissed => computedStatus == DoseLogStatus.missed;
  bool get isPending => computedStatus == DoseLogStatus.pending;
}
