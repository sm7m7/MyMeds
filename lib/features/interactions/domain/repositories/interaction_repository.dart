import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/interactions/domain/models/drug_interaction.dart';

/// Contract for checking drug-drug interactions.
///
/// Implementations may use a local bundled dataset (MVP) or a remote API
/// (e.g. openFDA Drug Interaction API, NLM RxNav) for production.
abstract class InteractionRepository {
  const InteractionRepository();

  /// Returns all pairwise interactions detected among [medications].
  ///
  /// Never throws; returns an empty list on any error.
  Future<List<DrugInteraction>> checkInteractions(
    List<Medication> medications,
  );

  /// Normalizes a brand/generic drug name to its primary active ingredient(s).
  ///
  /// Returns the normalized lowercase ingredient string, or the original name
  /// (lowercased) if no mapping is found.
  String normalizeToIngredient(String medicationName);
}
