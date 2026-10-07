import 'package:flutter/foundation.dart';

/// User-configurable settings for stock and expiration tracking.
@immutable
class InventorySettings {
  const InventorySettings({
    this.expiringSoonDaysThreshold = defaultExpiringSoonDays,
    this.lowStockThreshold = defaultLowStockThreshold,
    this.autoDecrementOnDoseTaken = true,
    this.dailyStockAlertsEnabled = true,
    this.dailyAlertHour = 9,
    this.dailyAlertMinute = 0,
  });

  /// Default threshold in days to mark a medication as expiring soon.
  static const int defaultExpiringSoonDays = 30;

  /// Default quantity at or below which a medication is marked as low stock.
  static const int defaultLowStockThreshold = 5;

  /// Number of days prior to expiration to flag medication as "expiring soon".
  final int expiringSoonDaysThreshold;

  /// Unit count threshold to flag medication as "low stock".
  final int lowStockThreshold;

  /// Whether to automatically deduct 1 dose unit from cabinet quantity when marked Taken.
  final bool autoDecrementOnDoseTaken;

  /// Whether to schedule daily notifications for expiring and low-stock items.
  final bool dailyStockAlertsEnabled;

  /// Hour of the day for daily notification check (0-23).
  final int dailyAlertHour;

  /// Minute of the hour for daily notification check (0-59).
  final int dailyAlertMinute;

  factory InventorySettings.fromJson(Map<String, dynamic> json) {
    return InventorySettings(
      expiringSoonDaysThreshold: (json['expiringSoonDaysThreshold'] as num?)?.toInt() ??
          defaultExpiringSoonDays,
      lowStockThreshold:
          (json['lowStockThreshold'] as num?)?.toInt() ?? defaultLowStockThreshold,
      autoDecrementOnDoseTaken:
          json['autoDecrementOnDoseTaken'] as bool? ?? true,
      dailyStockAlertsEnabled:
          json['dailyStockAlertsEnabled'] as bool? ?? true,
      dailyAlertHour: (json['dailyAlertHour'] as num?)?.toInt() ?? 9,
      dailyAlertMinute: (json['dailyAlertMinute'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expiringSoonDaysThreshold': expiringSoonDaysThreshold,
      'lowStockThreshold': lowStockThreshold,
      'autoDecrementOnDoseTaken': autoDecrementOnDoseTaken,
      'dailyStockAlertsEnabled': dailyStockAlertsEnabled,
      'dailyAlertHour': dailyAlertHour,
      'dailyAlertMinute': dailyAlertMinute,
    };
  }

  InventorySettings copyWith({
    int? expiringSoonDaysThreshold,
    int? lowStockThreshold,
    bool? autoDecrementOnDoseTaken,
    bool? dailyStockAlertsEnabled,
    int? dailyAlertHour,
    int? dailyAlertMinute,
  }) {
    return InventorySettings(
      expiringSoonDaysThreshold:
          expiringSoonDaysThreshold ?? this.expiringSoonDaysThreshold,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      autoDecrementOnDoseTaken:
          autoDecrementOnDoseTaken ?? this.autoDecrementOnDoseTaken,
      dailyStockAlertsEnabled:
          dailyStockAlertsEnabled ?? this.dailyStockAlertsEnabled,
      dailyAlertHour: dailyAlertHour ?? this.dailyAlertHour,
      dailyAlertMinute: dailyAlertMinute ?? this.dailyAlertMinute,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventorySettings &&
          runtimeType == other.runtimeType &&
          expiringSoonDaysThreshold == other.expiringSoonDaysThreshold &&
          lowStockThreshold == other.lowStockThreshold &&
          autoDecrementOnDoseTaken == other.autoDecrementOnDoseTaken &&
          dailyStockAlertsEnabled == other.dailyStockAlertsEnabled &&
          dailyAlertHour == other.dailyAlertHour &&
          dailyAlertMinute == other.dailyAlertMinute;

  @override
  int get hashCode =>
      expiringSoonDaysThreshold.hashCode ^
      lowStockThreshold.hashCode ^
      autoDecrementOnDoseTaken.hashCode ^
      dailyStockAlertsEnabled.hashCode ^
      dailyAlertHour.hashCode ^
      dailyAlertMinute.hashCode;
}
