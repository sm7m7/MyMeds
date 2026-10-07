import 'package:my_meds/features/cabinet/domain/models/medication.dart';

/// Contract for managing user medications stored in Firestore digital medicine cabinet.
abstract class CabinetRepository {
  /// Stream of medications for real-time synchronization with Firestore.
  Stream<List<Medication>> watchMedications(String userId);

  /// Fetches the current list of medications once.
  Future<List<Medication>> getMedications(String userId);

  /// Fetches a specific medication by its [medicationId].
  Future<Medication?> getMedicationById(String userId, String medicationId);

  /// Adds a new medication to the user's cabinet.
  Future<void> addMedication(String userId, Medication medication);

  /// Updates an existing medication in the user's cabinet.
  Future<void> updateMedication(String userId, Medication medication);

  /// Deletes a medication from the user's cabinet.
  Future<void> deleteMedication(String userId, String medicationId);
}
