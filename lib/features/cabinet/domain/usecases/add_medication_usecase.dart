import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/repositories/cabinet_repository.dart';

/// Use case to validate and persist a new medication into the user's cabinet.
class AddMedicationUseCase {
  const AddMedicationUseCase(this._repository);

  final CabinetRepository _repository;

  Future<void> call({
    required String userId,
    required Medication medication,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
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

    await _repository.addMedication(userId, medication);
  }
}
