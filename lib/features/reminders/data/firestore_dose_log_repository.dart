import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_meds/features/reminders/domain/models/dose_log.dart';
import 'package:my_meds/features/reminders/domain/repositories/dose_log_repository.dart';

/// Firestore implementation of [DoseLogRepository] at `users/{uid}/doseLogs/{id}`.
class FirestoreDoseLogRepository implements DoseLogRepository {
  FirestoreDoseLogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _logsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('doseLogs');
  }

  @override
  Stream<List<DoseLog>> watchDoseLogsForDay(String userId, DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day).toIso8601String();
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59, 999).toIso8601String();

    return _logsRef(userId)
        .where('scheduledTime', isGreaterThanOrEqualTo: startOfDay)
        .where('scheduledTime', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DoseLog.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<List<DoseLog>> getDoseLogsForRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    final snapshot = await _logsRef(userId)
        .where('scheduledTime', isGreaterThanOrEqualTo: startStr)
        .where('scheduledTime', isLessThanOrEqualTo: endStr)
        .get();

    return snapshot.docs.map((doc) {
      return DoseLog.fromJson(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<void> recordDoseLog(String userId, DoseLog log) async {
    final collection = _logsRef(userId);
    final docRef = log.id.isNotEmpty ? collection.doc(log.id) : collection.doc();
    final toSave = log.copyWith(id: docRef.id);
    await docRef.set(toSave.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteDoseLog(String userId, String logId) async {
    await _logsRef(userId).doc(logId).delete();
  }
}
