import 'package:my_meds/features/reminders/domain/models/dose_log.dart';

/// Repository interface managing recorded dose intake events in Firestore.
abstract class DoseLogRepository {
  /// Stream of dose logs for a given [userId] on a specific [day].
  Stream<List<DoseLog>> watchDoseLogsForDay(String userId, DateTime day);

  /// Fetch dose logs for a given [userId] in a date range.
  Future<List<DoseLog>> getDoseLogsForRange(
    String userId,
    DateTime start,
    DateTime end,
  );

  /// Record or update a dose intake log (Taken, Skipped, or Missed).
  Future<void> recordDoseLog(String userId, DoseLog log);

  /// Delete a dose log.
  Future<void> deleteDoseLog(String userId, String logId);
}
