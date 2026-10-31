import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/interactions/data/local_interaction_repository.dart';
import 'package:my_meds/features/interactions/domain/models/drug_interaction.dart';
import 'package:my_meds/features/interactions/domain/repositories/interaction_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the active [InteractionRepository] implementation.
///
/// Swap [LocalInteractionRepository] for a network-backed class here
/// when moving to production (NLM RxNav / openFDA).
final interactionRepositoryProvider = Provider<InteractionRepository>((ref) {
  return LocalInteractionRepository();
});

// ─────────────────────────────────────────────────────────────────────────────
// Cabinet-wide interactions
// ─────────────────────────────────────────────────────────────────────────────

/// Computes all pairwise interactions across the current user's cabinet.
///
/// Re-runs whenever the cabinet stream updates.
final cabinetInteractionsProvider =
    FutureProvider.autoDispose<List<DrugInteraction>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final medications =
      ref.watch(cabinetMedicationsStreamProvider).valueOrNull ?? [];
  if (medications.length < 2) return [];

  final repository = ref.watch(interactionRepositoryProvider);
  return repository.checkInteractions(medications);
});

// ─────────────────────────────────────────────────────────────────────────────
// New-medication interaction check
// ─────────────────────────────────────────────────────────────────────────────

/// Checks interactions between a [newMedication] and all [existingMedications].
///
/// Used by the add/edit form right before saving.
Future<List<DrugInteraction>> checkNewMedicationInteractions({
  required InteractionRepository repository,
  required Medication newMedication,
  required List<Medication> existingMedications,
}) {
  // Create a temporary list with the new medication appended.
  final allMeds = [...existingMedications, newMedication];
  return repository.checkInteractions(allMeds).then((all) {
    // Return only pairs that involve the new medication.
    return all
        .where((i) =>
            i.medicationAId == newMedication.id ||
            i.medicationBId == newMedication.id)
        .toList();
  });
}

/// Severity filter state for the interactions screen.
final interactionSeverityFilterProvider =
    StateProvider<InteractionSeverity?>((ref) => null);

/// Filtered & sorted interactions for the Interactions screen.
final filteredInteractionsProvider =
    Provider.autoDispose<AsyncValue<List<DrugInteraction>>>((ref) {
  final allAsync = ref.watch(cabinetInteractionsProvider);
  final severityFilter = ref.watch(interactionSeverityFilterProvider);

  return allAsync.whenData((interactions) {
    if (severityFilter == null) return interactions;
    return interactions
        .where((i) => i.severity == severityFilter)
        .toList();
  });
});
