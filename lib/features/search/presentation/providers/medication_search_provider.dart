import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/search/data/openfda_medication_repository.dart';
import 'package:my_meds/features/search/domain/medication_info.dart';
import 'package:my_meds/features/search/domain/medication_repository.dart';

/// Provider for the [MedicationRepository] implementation.
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return OpenFdaMedicationRepository();
});

/// Current active search query state.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Stream/Future provider for recent search terms.
final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  final repository = ref.watch(medicationRepositoryProvider);
  return RecentSearchesNotifier(repository);
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier(this._repository) : super([]) {
    loadSearches();
  }

  final MedicationRepository _repository;

  Future<void> loadSearches() async {
    final searches = await _repository.getRecentSearches();
    state = searches;
  }

  Future<void> addSearch(String query) async {
    await _repository.addRecentSearch(query);
    await loadSearches();
  }

  Future<void> clearAll() async {
    await _repository.clearRecentSearches();
    state = [];
  }
}

/// Provider that searches medications based on the current [searchQueryProvider].
final medicationSearchResultsProvider =
    FutureProvider.autoDispose<List<MedicationInfo>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return [];

  final repository = ref.watch(medicationRepositoryProvider);
  final results = await repository.searchMedications(query);

  // Refresh recent searches list after search
  ref.read(recentSearchesProvider.notifier).loadSearches();

  return results;
});
