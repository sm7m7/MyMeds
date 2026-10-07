import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_meds/features/search/data/medication_exception.dart';
import 'package:my_meds/features/search/domain/medication_info.dart';
import 'package:my_meds/features/search/domain/medication_repository.dart';

/// Implementation of [MedicationRepository] using the official OpenFDA Drug Label API.
///
/// Justification for OpenFDA over RxNorm:
/// 1. OpenFDA provides rich patient-oriented drug label data (purpose, indications,
///    detailed dosage, storage conditions, boxed warnings, and precautions) in a single JSON payload.
/// 2. RxNorm is primarily an ontology/identifier system (RxCUI) requiring multiple chained API calls
///    to retrieve similar clinical narrative fields.
/// 3. Free, public, well-documented, and requires no API key for standard mobile app query rates.
class OpenFdaMedicationRepository implements MedicationRepository {
  OpenFdaMedicationRepository({
    http.Client? httpClient,
    this._sharedPreferences,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  SharedPreferences? _sharedPreferences;

  static const String _baseUrl = 'https://api.fda.gov/drug/label.json';
  static const String _recentSearchesKey = 'recent_medication_searches';
  static const int _maxRecentSearches = 10;

  Future<SharedPreferences> _getPrefs() async {
    if (_sharedPreferences != null) return _sharedPreferences!;
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  @override
  Future<List<MedicationInfo>> searchMedications(
    String query, {
    int limit = 20,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    // Cache the search query term
    await addRecentSearch(trimmedQuery);

    try {
      // Build openFDA search expression across brand name, generic name, and substance name
      final sanitized = trimmedQuery.replaceAll(RegExp(r'[^a-zA-Z0-9\s-]'), '');
      final searchQuery =
          '(openfda.brand_name:"$sanitized"+openfda.generic_name:"$sanitized"+openfda.substance_name:"$sanitized")';
      final uri = Uri.parse('$_baseUrl?search=$searchQuery&limit=$limit');

      final response = await _httpClient.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic>? results = data['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) return [];

        return results
            .map((item) => _mapFdaResultToMedication(item as Map<String, dynamic>))
            .where((med) => med.name.isNotEmpty)
            .toList();
      } else if (response.statusCode == 404) {
        // OpenFDA returns 404 when no results match the search query
        return [];
      } else {
        throw MedicationException(
          'Failed to load medications (HTTP ${response.statusCode})',
        );
      }
    } on SocketException catch (e) {
      throw MedicationException(
        'Unable to connect to the medication database. Please check your internet connection.',
        cause: e,
        isOffline: true,
      );
    } on http.ClientException catch (e) {
      throw MedicationException(
        'Network error while connecting to medication service.',
        cause: e,
        isOffline: true,
      );
    } on FormatException catch (e) {
      throw MedicationException(
        'Failed to parse medication data response.',
        cause: e,
      );
    } catch (e) {
      if (e is MedicationException) rethrow;
      throw MedicationException('An unexpected error occurred while searching: $e');
    }
  }

  @override
  Future<MedicationInfo?> getMedicationById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl?search=set_id:"$id"&limit=1');
      final response = await _httpClient.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic>? results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          return _mapFdaResultToMedication(results.first as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      if (e is MedicationException) rethrow;
      throw MedicationException('Failed to fetch medication details: $e');
    }
  }

  @override
  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getStringList(_recentSearchesKey) ?? [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    try {
      final prefs = await _getPrefs();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];

      searches.removeWhere((item) => item.toLowerCase() == clean.toLowerCase());
      searches.insert(0, clean);

      if (searches.length > _maxRecentSearches) {
        searches.removeRange(_maxRecentSearches, searches.length);
      }

      await prefs.setStringList(_recentSearchesKey, searches);
    } catch (_) {}
  }

  @override
  Future<void> clearRecentSearches() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_recentSearchesKey);
    } catch (_) {}
  }

  MedicationInfo _mapFdaResultToMedication(Map<String, dynamic> map) {
    final openFda = map['openfda'] as Map<String, dynamic>? ?? {};

    // Name extraction
    final brandNames = (openFda['brand_name'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final genericNames = (openFda['generic_name'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final substanceNames = (openFda['substance_name'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final String displayName = brandNames.isNotEmpty
        ? brandNames.first
        : (genericNames.isNotEmpty
            ? genericNames.first
            : (substanceNames.isNotEmpty
                ? substanceNames.first
                : 'Medication ${map['id'] ?? ''}'));

    final String? genericName =
        genericNames.isNotEmpty ? genericNames.join(', ') : null;

    // Narrative section extractors helper
    String? extractSection(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        if (value.isEmpty) return null;
        return value.map((e) => e.toString().trim()).join('\n\n');
      }
      return value.toString().trim();
    }

    // Purpose & Indication
    final String? purpose = extractSection(map['purpose']);
    final String? indications = extractSection(map['indications_and_usage']) ??
        extractSection(map['description']);

    // Dosage & Administration
    final String? dosage = extractSection(map['dosage_and_administration']);

    // Storage conditions
    final String? storage = extractSection(map['storage_and_handling']) ??
        extractSection(map['how_supplied']);

    // Warnings & Precautions
    final String? warnings = extractSection(map['warnings']) ??
        extractSection(map['warnings_and_cautions']) ??
        extractSection(map['precautions']);

    // Boxed Warning
    final String? boxedWarning = extractSection(map['boxed_warning']);

    // Active Ingredients
    final List<String> activeIngredients = (map['active_ingredient'] as List<dynamic>?)
            ?.map((e) => e.toString().trim())
            .toList() ??
        substanceNames;

    // Routes
    final List<String> routes = (openFda['route'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Product Type
    final String? productType = (openFda['product_type'] as List<dynamic>?)?.firstOrNull?.toString();

    final String id = map['set_id'] as String? ??
        (map['id'] as String? ??
            (openFda['spl_id'] as List<dynamic>?)?.firstOrNull?.toString() ??
            displayName.toLowerCase().replaceAll(' ', '_'));

    return MedicationInfo(
      id: id,
      name: displayName,
      genericName: genericName,
      brandNames: brandNames,
      purpose: purpose,
      indicationsAndUsage: indications,
      dosageAndAdministration: dosage,
      storageAndHandling: storage,
      warnings: warnings,
      boxedWarning: boxedWarning,
      activeIngredients: activeIngredients,
      route: routes,
      productType: productType,
    );
  }
}
