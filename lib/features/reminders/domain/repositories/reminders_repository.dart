import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';

/// Repository interface managing medication reminder rules.
abstract class RemindersRepository {
  /// Stream of reminders for a given [userId].
  Stream<List<MedicationReminder>> watchReminders(String userId);

  /// Fetch all reminders for a given [userId].
  Future<List<MedicationReminder>> getReminders(String userId);

  /// Fetch a single reminder by [reminderId].
  Future<MedicationReminder?> getReminderById(String userId, String reminderId);

  /// Create a new reminder.
  Future<void> addReminder(String userId, MedicationReminder reminder);

  /// Update an existing reminder.
  Future<void> updateReminder(String userId, MedicationReminder reminder);

  /// Delete a reminder.
  Future<void> deleteReminder(String userId, String reminderId);

  /// Toggle active status of a reminder.
  Future<void> toggleReminderActive(String userId, String reminderId, bool isActive);
}
