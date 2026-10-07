import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/repositories/cabinet_repository.dart';

/// Use case to stream real-time cabinet medications for a user.
class WatchMedicationsUseCase {
  const WatchMedicationsUseCase(this._repository);

  final CabinetRepository _repository;

  Stream<List<Medication>> call(String userId) {
    if (userId.trim().isEmpty) return Stream.value([]);
    return _repository.watchMedications(userId);
  }
}
