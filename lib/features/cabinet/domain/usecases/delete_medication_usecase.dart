import 'package:my_meds/features/cabinet/domain/repositories/cabinet_repository.dart';

/// Use case to delete a medication from the user's digital cabinet.
class DeleteMedicationUseCase {
  const DeleteMedicationUseCase(this._repository);

  final CabinetRepository _repository;

  Future<void> call({
    required String userId,
    required String medicationId,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }
    if (medicationId.trim().isEmpty) {
      throw ArgumentError('Medication ID cannot be empty.');
    }

    await _repository.deleteMedication(userId, medicationId);
  }
}
