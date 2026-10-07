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

  /// Cancel all scheduled notifications in the app.
  Future<void> cancelAllNotifications();
}
