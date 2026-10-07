import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/cabinet/data/firestore_cabinet_repository.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_status.dart';
import 'package:my_meds/features/cabinet/domain/repositories/cabinet_repository.dart';
import 'package:my_meds/features/cabinet/domain/usecases/add_medication_usecase.dart';
import 'package:my_meds/features/cabinet/domain/usecases/delete_medication_usecase.dart';
import 'package:my_meds/features/cabinet/domain/usecases/filter_medications_usecase.dart';
import 'package:my_meds/features/cabinet/domain/usecases/update_medication_usecase.dart';
import 'package:my_meds/features/cabinet/domain/usecases/watch_medications_usecase.dart';

/// Repository provider.
final cabinetRepositoryProvider = Provider<CabinetRepository>((ref) {
  return FirestoreCabinetRepository();
});

/// Use cases providers.
final watchMedicationsUseCaseProvider = Provider<WatchMedicationsUseCase>((ref) {
  return WatchMedicationsUseCase(ref.watch(cabinetRepositoryProvider));
});

final addMedicationUseCaseProvider = Provider<AddMedicationUseCase>((ref) {
  return AddMedicationUseCase(ref.watch(cabinetRepositoryProvider));
});

final updateMedicationUseCaseProvider = Provider<UpdateMedicationUseCase>((ref) {
  return UpdateMedicationUseCase(ref.watch(cabinetRepositoryProvider));
});

final deleteMedicationUseCaseProvider = Provider<DeleteMedicationUseCase>((ref) {
  return DeleteMedicationUseCase(ref.watch(cabinetRepositoryProvider));
});

final filterMedicationsUseCaseProvider = Provider<FilterMedicationsUseCase>((ref) {
  return const FilterMedicationsUseCase();
});

/// Search and filter state providers.
final cabinetSearchQueryProvider = StateProvider<String>((ref) => '');
final cabinetFormFilterProvider = StateProvider<MedicationForm?>((ref) => null);
final cabinetStatusFilterProvider =
    StateProvider<MedicationStatus?>((ref) => null);

/// Real-time stream of the current authenticated user's medications.
final cabinetMedicationsStreamProvider =
    StreamProvider.autoDispose<List<Medication>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final watchUseCase = ref.watch(watchMedicationsUseCaseProvider);
  return watchUseCase(user.uid);
});

/// Computes filtered & sorted medications based on search query, form, and status filters.
final filteredCabinetMedicationsProvider =
    Provider.autoDispose<List<Medication>>((ref) {
  final allMedications =
      ref.watch(cabinetMedicationsStreamProvider).valueOrNull ?? [];
  final query = ref.watch(cabinetSearchQueryProvider);
  final formFilter = ref.watch(cabinetFormFilterProvider);
  final statusFilter = ref.watch(cabinetStatusFilterProvider);
  final filterUseCase = ref.watch(filterMedicationsUseCaseProvider);

  return filterUseCase(
    medications: allMedications,
    query: query,
    formFilter: formFilter,
    statusFilter: statusFilter,
  );
});

/// Controller for cabinet CRUD actions.
class CabinetController extends StateNotifier<AsyncValue<void>> {
  CabinetController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> addMedication(Medication medication) async {
    state = const AsyncValue.loading();
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncValue.error(
        'You must be signed in to add medications.',
        StackTrace.current,
      );
      return false;
    }

    state = await AsyncValue.guard(() async {
      final addUseCase = _ref.read(addMedicationUseCaseProvider);
      await addUseCase(userId: user.uid, medication: medication);
    });

    return !state.hasError;
  }

  Future<bool> updateMedication(Medication medication) async {
    state = const AsyncValue.loading();
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncValue.error(
        'You must be signed in to update medications.',
        StackTrace.current,
      );
      return false;
    }

    state = await AsyncValue.guard(() async {
      final updateUseCase = _ref.read(updateMedicationUseCaseProvider);
      await updateUseCase(userId: user.uid, medication: medication);
    });

    return !state.hasError;
  }

  Future<bool> deleteMedication(String medicationId) async {
    state = const AsyncValue.loading();
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncValue.error(
        'You must be signed in to delete medications.',
        StackTrace.current,
      );
      return false;
    }

    state = await AsyncValue.guard(() async {
      final deleteUseCase = _ref.read(deleteMedicationUseCaseProvider);
      await deleteUseCase(userId: user.uid, medicationId: medicationId);
    });

    return !state.hasError;
  }

  Future<bool> adjustQuantity(Medication medication, int delta) async {
    final newQuantity = (medication.quantity + delta).clamp(0, 99999);
    final updated = medication.copyWith(quantity: newQuantity);
    return updateMedication(updated);
  }
}

final cabinetControllerProvider =
    StateNotifierProvider<CabinetController, AsyncValue<void>>((ref) {
  return CabinetController(ref);
});
