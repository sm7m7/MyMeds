import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';
import 'package:my_meds/features/reminders/domain/repositories/reminders_repository.dart';

/// Firestore implementation of [RemindersRepository] at `users/{uid}/reminders/{id}`.
class FirestoreRemindersRepository implements RemindersRepository {
  FirestoreRemindersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _remindersRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('reminders');
  }

  @override
  Stream<List<MedicationReminder>> watchReminders(String userId) {
    return _remindersRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MedicationReminder.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<List<MedicationReminder>> getReminders(String userId) async {
    final snapshot = await _remindersRef(userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      return MedicationReminder.fromJson(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<MedicationReminder?> getReminderById(
    String userId,
    String reminderId,
  ) async {
    final doc = await _remindersRef(userId).doc(reminderId).get();
    if (!doc.exists || doc.data() == null) return null;
    return MedicationReminder.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<void> addReminder(String userId, MedicationReminder reminder) async {
    final collection = _remindersRef(userId);
    final docRef = reminder.id.isNotEmpty
        ? collection.doc(reminder.id)
        : collection.doc();

    final toSave = reminder.copyWith(
      id: docRef.id,
      createdAt: reminder.createdAt,
    );
    await docRef.set(toSave.toJson());
  }

  @override
  Future<void> updateReminder(String userId, MedicationReminder reminder) async {
    final docRef = _remindersRef(userId).doc(reminder.id);
    await docRef.update(reminder.copyWith(updatedAt: DateTime.now()).toJson());
  }

  @override
  Future<void> deleteReminder(String userId, String reminderId) async {
    await _remindersRef(userId).doc(reminderId).delete();
  }

  @override
  Future<void> toggleReminderActive(
    String userId,
    String reminderId,
    bool isActive,
  ) async {
    final docRef = _remindersRef(userId).doc(reminderId);
    await docRef.update({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
