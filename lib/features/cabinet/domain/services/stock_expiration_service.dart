import 'dart:math' as math;
import 'package:my_meds/features/cabinet/domain/models/inventory_settings.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_status.dart';

/// Comprehensive inventory status analysis for a medication.
class MedicationInventoryStatus {
  const MedicationInventoryStatus({
    required this.isExpired,
    required this.isExpiringSoon,
    required this.isLowStock,
    required this.isOutOfStock,
    required this.isOk,
    required this.daysUntilExpiration,
    required this.primaryStatus,
    required this.allStatuses,
    required this.attentionNeeded,
    required this.attentionReason,
  });

  /// Whether the medication has passed its expiration date.
  final bool isExpired;

  /// Whether the medication expires within the configured threshold days.
  final bool isExpiringSoon;

  /// Whether the remaining stock is at or below the low stock threshold.
  final bool isLowStock;

  /// Whether quantity is exactly 0.
  final bool isOutOfStock;

  /// Whether the medication is in ideal condition (valid, safe, in stock).
  final bool isOk;

  /// Days remaining until expiration (negative if already expired).
  final int daysUntilExpiration;

  /// Primary priority status (Expired > Expiring Soon > Low Stock > OK).
  final MedicationStatus primaryStatus;

  /// All active status badges.
  final List<MedicationStatus> allStatuses;

  /// Whether this medication requires user attention (expired, expiring soon, or low stock).
  final bool attentionNeeded;

  /// Human-readable explanation of why attention is needed (or null if OK).
  final String? attentionReason;
}

/// Pure Dart service handling expiration date normalization, inventory classification,
/// threshold configuration, and stock decrementing logic.
class StockExpirationService {
  const StockExpirationService();

  /// Default settings used when none are provided.
  static const InventorySettings defaultSettings = InventorySettings();

  /// Returns the number of days in a given [month] and [year], accurately accounting for leap years.
  static int getDaysInMonth(int year, int month) {
    // In Dart DateTime, day 0 of month + 1 resolves to the last day of month.
    return DateTime(year, month + 1, 0).day;
  }

  /// Parses diverse expiration date representations into a concrete [DateTime].
  ///
  /// For month-only formats (e.g., "06/2028", "2028-06", "02/28"), the expiration date
  /// is set to the **end of that month** (23:59:59 on the last day), following standard
  /// pharmaceutical labeling regulations.
  static DateTime parseExpirationDate(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return DateTime.now();

    // 1. Standard ISO YYYY-MM-DD or YYYY/MM/DD
    final fullDateMatch =
        RegExp(r'^(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})').firstMatch(clean);
    if (fullDateMatch != null) {
      final year = int.parse(fullDateMatch.group(1)!);
      final month = int.parse(fullDateMatch.group(2)!);
      final day = int.parse(fullDateMatch.group(3)!);
      return DateTime(year, month, day, 23, 59, 59);
    }

    // 2. Month-only: MM/YYYY or MM-YYYY (e.g. 06/2028)
    final myMatch =
        RegExp(r'^(\d{1,2})[\/\-](\d{4})$').firstMatch(clean);
    if (myMatch != null) {
      final month = int.parse(myMatch.group(1)!);
      final year = int.parse(myMatch.group(2)!);
      final lastDay = getDaysInMonth(year, month);
      return DateTime(year, month, lastDay, 23, 59, 59);
    }

    // 3. Month-only: YYYY-MM or YYYY/MM (e.g. 2028-06)
    final ymMatch =
        RegExp(r'^(\d{4})[\/\-](\d{1,2})$').firstMatch(clean);
    if (ymMatch != null) {
      final year = int.parse(ymMatch.group(1)!);
      final month = int.parse(ymMatch.group(2)!);
      final lastDay = getDaysInMonth(year, month);
      return DateTime(year, month, lastDay, 23, 59, 59);
    }

    // 4. Short year month-only: MM/YY or MM-YY (e.g. 02/28)
    final shortMyMatch =
        RegExp(r'^(\d{1,2})[\/\-](\d{2})$').firstMatch(clean);
    if (shortMyMatch != null) {
      final month = int.parse(shortMyMatch.group(1)!);
      final shortYear = int.parse(shortMyMatch.group(2)!);
      final year = 2000 + shortYear;
      final lastDay = getDaysInMonth(year, month);
      return DateTime(year, month, lastDay, 23, 59, 59);
    }

    // 5. Fallback DateTime.tryParse
    final fallback = DateTime.tryParse(clean);
    if (fallback != null) {
      return DateTime(fallback.year, fallback.month, fallback.day, 23, 59, 59);
    }

    return DateTime.now();
  }

  /// Evaluates and classifies a [medication] based on current time [now] and [settings].
  MedicationInventoryStatus classifyMedication(
    Medication medication, {
    DateTime? now,
    InventorySettings settings = defaultSettings,
  }) {
    final current = now ?? DateTime.now();
    final todayStart = DateTime(current.year, current.month, current.day);
    final expDate = medication.expirationDate;
    final expDateOnly = DateTime(expDate.year, expDate.month, expDate.day);

    // Days difference
    final daysRemaining = expDateOnly.difference(todayStart).inDays;

    // 1. Expired check: expiration date is strictly before today
    final bool isExpired = daysRemaining < 0;

    // 2. Expiring soon check: not expired, and expires within threshold days (including today)
    final bool isExpiringSoon = !isExpired &&
        daysRemaining <= settings.expiringSoonDaysThreshold;

    // 3. Low stock check
    final bool isOutOfStock = medication.quantity <= 0;
    final bool isLowStock = medication.quantity <= settings.lowStockThreshold;

    // 4. OK check
    final bool isOk = !isExpired && !isExpiringSoon && !isLowStock;

    // 5. Determine primary status
    final MedicationStatus primaryStatus;
    if (isExpired) {
      primaryStatus = MedicationStatus.expired;
    } else if (isExpiringSoon) {
      primaryStatus = MedicationStatus.expiringSoon;
    } else if (isLowStock) {
      primaryStatus = MedicationStatus.lowStock;
    } else {
      primaryStatus = MedicationStatus.ok;
    }

    // 6. Collect all active statuses
    final allStatuses = <MedicationStatus>[];
    if (isExpired) {
      allStatuses.add(MedicationStatus.expired);
    } else if (isExpiringSoon) {
      allStatuses.add(MedicationStatus.expiringSoon);
    }
    if (isLowStock) {
      allStatuses.add(MedicationStatus.lowStock);
    }
    if (allStatuses.isEmpty) {
      allStatuses.add(MedicationStatus.ok);
    }

    // 7. Attention needed flag and reason description
    final bool attentionNeeded = isExpired || isExpiringSoon || isLowStock;
    String? reason;

    if (isExpired) {
      final daysAgo = daysRemaining.abs();
      reason = daysAgo == 0
          ? 'Expired yesterday'
          : 'Expired $daysAgo day${daysAgo > 1 ? 's' : ''} ago';
    } else if (isExpiringSoon) {
      if (daysRemaining == 0) {
        reason = 'Expires today';
      } else if (daysRemaining == 1) {
        reason = 'Expires tomorrow';
      } else {
        reason = 'Expires in $daysRemaining days';
      }
    }

    if (isOutOfStock) {
      reason = reason != null ? '$reason • Out of stock' : 'Out of stock (0 units)';
    } else if (isLowStock) {
      final stockNote = 'Low stock (${medication.quantity} left)';
      reason = reason != null ? '$reason • $stockNote' : stockNote;
    }

    return MedicationInventoryStatus(
      isExpired: isExpired,
      isExpiringSoon: isExpiringSoon,
      isLowStock: isLowStock,
      isOutOfStock: isOutOfStock,
      isOk: isOk,
      daysUntilExpiration: daysRemaining,
      primaryStatus: primaryStatus,
      allStatuses: allStatuses,
      attentionNeeded: attentionNeeded,
      attentionReason: reason,
    );
  }

  /// Filters list of medications to only those requiring attention (expired, expiring soon, low stock).
  List<Medication> filterAttentionNeeded(
    List<Medication> medications, {
    DateTime? now,
    InventorySettings settings = defaultSettings,
  }) {
    return medications.where((m) {
      final status = classifyMedication(m, now: now, settings: settings);
      return status.attentionNeeded;
    }).toList();
  }

  /// Filters list to only expired medications.
  List<Medication> filterExpired(
    List<Medication> medications, {
    DateTime? now,
    InventorySettings settings = defaultSettings,
  }) {
    return medications.where((m) {
      return classifyMedication(m, now: now, settings: settings).isExpired;
    }).toList();
  }

  /// Filters list to only expiring soon medications.
  List<Medication> filterExpiringSoon(
    List<Medication> medications, {
    DateTime? now,
    InventorySettings settings = defaultSettings,
  }) {
    return medications.where((m) {
      return classifyMedication(m, now: now, settings: settings).isExpiringSoon;
    }).toList();
  }

  /// Filters list to only low stock medications.
  List<Medication> filterLowStock(
    List<Medication> medications, {
    DateTime? now,
    InventorySettings settings = defaultSettings,
  }) {
    return medications.where((m) {
      return classifyMedication(m, now: now, settings: settings).isLowStock;
    }).toList();
  }

  /// Decrements the quantity of [medication] by [doseUnits], clamped to minimum 0.
  Medication decrementQuantity(
    Medication medication, {
    int doseUnits = 1,
  }) {
    final newQuantity = math.max(0, medication.quantity - doseUnits);
    return medication.copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );
  }

  /// Generates a summary notification text for inventory alerts.
  String? generateAlertNotificationBody(
    List<Medication> medications, {
    DateTime? now,
    InventorySettings settings = defaultSettings,
  }) {
    final expired = filterExpired(medications, now: now, settings: settings);
    final expiring = filterExpiringSoon(medications, now: now, settings: settings);
    final lowStock = filterLowStock(medications, now: now, settings: settings);

    final parts = <String>[];
    if (expired.isNotEmpty) {
      parts.add('${expired.length} expired');
    }
    if (expiring.isNotEmpty) {
      parts.add('${expiring.length} expiring soon');
    }
    if (lowStock.isNotEmpty) {
      parts.add('${lowStock.length} low in stock');
    }

    if (parts.isEmpty) return null;
    return 'Medicine Cabinet Alert: ${parts.join(', ')}. Check your cabinet for details.';
  }
}
