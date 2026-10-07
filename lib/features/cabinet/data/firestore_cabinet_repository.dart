import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/repositories/cabinet_repository.dart';

/// Firestore implementation of [CabinetRepository] storing data at `users/{uid}/medications/{id}`.
class FirestoreCabinetRepository implements CabinetRepository {
  FirestoreCabinetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _medicationsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('medications');
  }

  @override
  Stream<List<Medication>> watchMedications(String userId) {
    return _medicationsRef(userId)
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Medication.fromJson(doc.data(), id: doc.id);
      }).toList();
    });
  }

  @override
  Future<List<Medication>> getMedications(String userId) async {
    final snapshot =
        await _medicationsRef(userId).orderBy('name', descending: false).get();
    return snapshot.docs.map((doc) {
      return Medication.fromJson(doc.data(), id: doc.id);
    }).toList();
  }

  @override
  Future<Medication?> getMedicationById(
    String userId,
    String medicationId,
  ) async {
    final doc = await _medicationsRef(userId).doc(medicationId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Medication.fromJson(doc.data()!, id: doc.id);
  }

  @override
  Future<void> addMedication(String userId, Medication medication) async {
    final collection = _medicationsRef(userId);
    final docRef = medication.id.isNotEmpty
        ? collection.doc(medication.id)
        : collection.doc();

    final toSave = medication.copyWith(id: docRef.id);
    await docRef.set(toSave.toJson());
  }

  @override
  Future<void> updateMedication(String userId, Medication medication) async {
    final docRef = _medicationsRef(userId).doc(medication.id);
    await docRef.update(medication.toJson());
  }

  @override
  Future<void> deleteMedication(String userId, String medicationId) async {
    await _medicationsRef(userId).doc(medicationId).delete();
  }
}
