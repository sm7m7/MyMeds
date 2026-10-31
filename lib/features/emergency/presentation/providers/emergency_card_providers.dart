import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/emergency/data/firestore_emergency_card_repository.dart';
import 'package:my_meds/features/emergency/domain/models/emergency_card_data.dart';
import 'package:my_meds/features/emergency/domain/repositories/emergency_card_repository.dart';
import 'package:my_meds/features/emergency/domain/services/emergency_card_pdf_service.dart';

// ── Dependency Providers ──────────────────────────────────────────────────────

final emergencyCardRepositoryProvider =
    Provider<EmergencyCardRepository>((ref) {
  return FirestoreEmergencyCardRepository();
});

final emergencyCardPdfServiceProvider =
    Provider<EmergencyCardPdfService>((ref) {
  return const EmergencyCardPdfService();
});

// ── State Providers ──────────────────────────────────────────────────────────

/// Real-time stream of the current user's emergency card data.
final emergencyCardStreamProvider =
    StreamProvider.autoDispose<EmergencyCardData?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(emergencyCardRepositoryProvider);
  return repository.watchEmergencyCard(user.uid);
});

/// Combined state class for emergency card profile and cabinet medications.
class EmergencyCardFullView {
  const EmergencyCardFullView({
    required this.card,
    required this.medications,
  });

  final EmergencyCardData card;
  final List<Medication> medications;
}

/// Combined provider that merges emergency profile data with the user's active cabinet medications.
final emergencyCardFullViewProvider =
    Provider.autoDispose<EmergencyCardFullView>((ref) {
  final cardData = ref.watch(emergencyCardStreamProvider).valueOrNull ??
      const EmergencyCardData(fullName: '');
  final medications =
      ref.watch(cabinetMedicationsStreamProvider).valueOrNull ?? [];

  return EmergencyCardFullView(
    card: cardData,
    medications: medications,
  );
});

/// Controller for saving / updating emergency card data.
class EmergencyCardController extends StateNotifier<AsyncValue<void>> {
  EmergencyCardController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> saveCard(EmergencyCardData data) async {
    state = const AsyncValue.loading();
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncValue.error(
        'You must be signed in to save an emergency card.',
        StackTrace.current,
      );
      return false;
    }

    state = await AsyncValue.guard(() async {
      final repository = _ref.read(emergencyCardRepositoryProvider);
      await repository.saveEmergencyCard(user.uid, data);
    });

    return !state.hasError;
  }
}

final emergencyCardControllerProvider =
    StateNotifierProvider<EmergencyCardController, AsyncValue<void>>((ref) {
  return EmergencyCardController(ref);
});
