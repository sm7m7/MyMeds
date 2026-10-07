import 'package:my_meds/features/cabinet/domain/models/inventory_settings.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';

/// Abstract service handling local and push medication notifications.
abstract class NotificationService {
  /// Initialize local notification channels and plugins.
  Future<void> initialize();

  /// Request notification permissions (Android 13+ and iOS).
  Future<bool> requestPermissions();

  /// Schedule recurring or scheduled notifications for a [reminder].
  Future<void> scheduleReminderNotifications(MedicationReminder reminder);

  /// Cancel all scheduled notifications for a [reminderId].
  Future<void> cancelReminderNotifications(String reminderId);

  /// Schedules daily recurring inventory alerts for expired, expiring, or low-stock items.
  Future<void> scheduleDailyInventoryAlert(
    List<Medication> medications,
    InventorySettings settings,
  );

  /// Cancel all scheduled notifications in the app.
  Future<void> cancelAllNotifications();
}
