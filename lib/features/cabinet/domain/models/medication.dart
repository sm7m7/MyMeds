import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_status.dart';

/// Domain entity representing a medication stored in the user's digital medicine cabinet.
class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.form,
    required this.quantity,
    required this.expirationDate,
    this.storageConditions,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String dosage;
  final MedicationForm form;
  final int quantity;
  final DateTime expirationDate;
  final String? storageConditions;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Low stock threshold.
  static const int lowStockThreshold = 5;

  /// Days threshold to consider a medication "expiring soon".
  static const int expiringSoonDaysThreshold = 30;

  /// Calculates whether this medication is expired relative to [now].
  bool isExpired([DateTime? now]) {
    final current = now ?? DateTime.now();
    return expirationDate.isBefore(DateTime(current.year, current.month, current.day));
  }

  /// Calculates whether this medication expires within [expiringSoonDaysThreshold] days.
  bool isExpiringSoon([DateTime? now]) {
    final current = now ?? DateTime.now();
    if (isExpired(current)) return false;
    final thresholdDate = current.add(const Duration(days: expiringSoonDaysThreshold));
    return expirationDate.isBefore(thresholdDate) || expirationDate.isAtSameMomentAs(thresholdDate);
  }

  /// Calculates whether inventory is low.
  bool get isLowStock => quantity <= lowStockThreshold;

  /// Calculates whether the medication is in ideal condition.
  bool isOk([DateTime? now]) => !isExpired(now) && !isExpiringSoon(now) && !isLowStock;

  /// Returns days remaining until expiration. Negative if already expired.
  int daysUntilExpiration([DateTime? now]) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final exp = DateTime(expirationDate.year, expirationDate.month, expirationDate.day);
    return exp.difference(today).inDays;
  }

  /// Primary priority status: Expired > Expiring Soon > Low Stock > OK.
  MedicationStatus getPrimaryStatus([DateTime? now]) {
    if (isExpired(now)) return MedicationStatus.expired;
    if (isExpiringSoon(now)) return MedicationStatus.expiringSoon;
    if (isLowStock) return MedicationStatus.lowStock;
    return MedicationStatus.ok;
  }

  /// Returns all active status badges applicable to this medication.
  List<MedicationStatus> getAllStatuses([DateTime? now]) {
    final statuses = <MedicationStatus>[];
    if (isExpired(now)) {
      statuses.add(MedicationStatus.expired);
    } else if (isExpiringSoon(now)) {
      statuses.add(MedicationStatus.expiringSoon);
    }

    if (isLowStock) {
      statuses.add(MedicationStatus.lowStock);
    }

    if (statuses.isEmpty) {
      statuses.add(MedicationStatus.ok);
    }
    return statuses;
  }

  /// Validates medication field rules. Returns an error message or null if valid.
  static String? validateInput({
    required String name,
    required String dosage,
    required int? quantity,
    required DateTime? expirationDate,
  }) {
    if (name.trim().isEmpty) {
      return 'Medication name cannot be empty.';
    }
    if (dosage.trim().isEmpty) {
      return 'Dosage cannot be empty.';
    }
    if (quantity == null || quantity < 0) {
      return 'Quantity must be a positive integer or 0.';
    }
    if (expirationDate == null) {
      return 'Expiration date is required.';
    }
    return null;
  }

  /// Deserializes Firestore map to [Medication].
  factory Medication.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      // Firestore Timestamp support
      try {
        return (val as dynamic).toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }

    return Medication(
      id: id ?? (json['id'] as String? ?? ''),
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      form: MedicationForm.fromString(json['form'] as String?),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      expirationDate: parseDate(json['expirationDate']),
      storageConditions: json['storageConditions'] as String?,
      notes: json['notes'] as String?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
    );
  }

  /// Serializes [Medication] to Firestore map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'form': form.name,
      'quantity': quantity,
      'expirationDate': expirationDate.toIso8601String(),
      'storageConditions': storageConditions,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a modified copy of this [Medication].
  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    MedicationForm? form,
    int? quantity,
    DateTime? expirationDate,
    String? storageConditions,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      quantity: quantity ?? this.quantity,
      expirationDate: expirationDate ?? this.expirationDate,
      storageConditions: storageConditions ?? this.storageConditions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medication &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          dosage == other.dosage &&
          form == other.form &&
          quantity == other.quantity &&
          expirationDate.isAtSameMomentAs(other.expirationDate);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      dosage.hashCode ^
      form.hashCode ^
      quantity.hashCode ^
      expirationDate.hashCode;
}
