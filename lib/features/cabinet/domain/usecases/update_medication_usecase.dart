import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/repositories/cabinet_repository.dart';

/// Use case to validate and update an existing medication in the user's cabinet.
class UpdateMedicationUseCase {
  const UpdateMedicationUseCase(this._repository);

  final CabinetRepository _repository;

  Future<void> call({
    required String userId,
    required Medication medication,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }
    if (medication.id.trim().isEmpty) {
      throw ArgumentError('Medication ID cannot be empty.');
    }

    final validationError = Medication.validateInput(
      name: medication.name,
      dosage: medication.dosage,
      quantity: medication.quantity,
      expirationDate: medication.expirationDate,
    );

    if (validationError != null) {
      throw FormatException(validationError);
    }

    final updated = medication.copyWith(updatedAt: DateTime.now());
    await _repository.updateMedication(userId, updated);
  }
}
