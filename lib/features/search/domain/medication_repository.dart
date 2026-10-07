import 'package:my_meds/features/search/domain/medication_info.dart';

/// Abstract contract for searching and retrieving medication data from an open API.
abstract class MedicationRepository {
  /// Searches for medications matching [query].
  ///
  /// Returns a list of [MedicationInfo] objects, or an empty list if no matches found.
  Future<List<MedicationInfo>> searchMedications(
    String query, {
    int limit = 20,
  });

  /// Retrieves a specific medication by its identifier.
  Future<MedicationInfo?> getMedicationById(String id);

  /// Retrieves the list of recently searched terms from local cache.
  Future<List<String>> getRecentSearches();

  /// Adds a new search term to the recent searches cache.
  Future<void> addRecentSearch(String query);

  /// Clears all recent searches from local cache.
  Future<void> clearRecentSearches();
}
