import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/interactions/domain/models/drug_interaction.dart';
import 'package:my_meds/features/interactions/domain/repositories/interaction_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data source strategy
// ─────────────────────────────────────────────────────────────────────────────
//
// MVP: Bundled local JSON at assets/interactions/known_interactions.json.
//      ~25 well-known, clinically significant pairs.
//
// Production upgrade path:
//   • NLM RxNav Interaction API (free, no API key):
//       https://rxnav.nlm.nih.gov/InteractionAPIs.html
//   • openFDA Drug Interaction endpoint:
//       https://api.fda.gov/drug/drugsfda.json
//   Simply swap this class with a network-backed implementation that
//   still satisfies the [InteractionRepository] interface.
//
// ─────────────────────────────────────────────────────────────────────────────

/// MVP implementation backed by a bundled JSON dataset.
///
/// The JSON is loaded once and cached for the app's lifetime.
class LocalInteractionRepository extends InteractionRepository {
  LocalInteractionRepository();

  List<InteractionEntry>? _cache;

  // ── Brand → active ingredient normalization table ─────────────────────────
  //
  // Maps common brand names and alternate spellings to the canonical
  // ingredient name used in the interactions JSON.
  //
  // All keys and values are lowercase. Substring matching is used
  // (see [normalizeToIngredient]), so partial brand names also resolve.
  static const Map<String, String> _ingredientMap = {
    // Analgesics / NSAIDs
    'advil': 'ibuprofen',
    'motrin': 'ibuprofen',
    'nurofen': 'ibuprofen',
    'aleve': 'naproxen',
    'naprosyn': 'naproxen',
    'tylenol': 'acetaminophen',
    'panadol': 'acetaminophen',
    'paracetamol': 'acetaminophen',
    'aspirin': 'aspirin',
    'bayer': 'aspirin',
    'ecotrin': 'aspirin',

    // Anticoagulants
    'coumadin': 'warfarin',
    'jantoven': 'warfarin',
    'xarelto': 'rivaroxaban',
    'eliquis': 'apixaban',
    'pradaxa': 'dabigatran',
    'plavix': 'clopidogrel',

    // Statins
    'lipitor': 'atorvastatin',
    'crestor': 'rosuvastatin',
    'zocor': 'simvastatin',
    'mevacor': 'lovastatin',

    // Proton Pump Inhibitors
    'prilosec': 'omeprazole',
    'nexium': 'esomeprazole',
    'prevacid': 'lansoprazole',
    'protonix': 'pantoprazole',
    'zegerid': 'omeprazole',

    // Antibiotics
    'biaxin': 'clarithromycin',
    'zithromax': 'azithromycin',
    'cipro': 'ciprofloxacin',
    'flagyl': 'metronidazole',
    'augmentin': 'amoxicillin',
    'amoxil': 'amoxicillin',

    // Cardiac
    'cordarone': 'amiodarone',
    'pacerone': 'amiodarone',
    'lanoxin': 'digoxin',
    'nitrostat': 'nitroglycerin',
    'imdur': 'isosorbide',
    'isordil': 'isosorbide',

    // Antidiabetics
    'glucophage': 'metformin',
    'glumetza': 'metformin',

    // Antihypertensives
    'zestril': 'lisinopril',
    'prinivil': 'lisinopril',
    'aldactone': 'spironolactone',

    // Thyroid
    'synthroid': 'levothyroxine',
    'levoxyl': 'levothyroxine',
    'eltroxin': 'levothyroxine',

    // Pain / Opioids
    'ultram': 'tramadol',
    'conzip': 'tramadol',

    // Erectile dysfunction
    'viagra': 'sildenafil',
    'revatio': 'sildenafil',
    'cialis': 'tadalafil',

    // Benzodiazepines
    'xanax': 'alprazolam',
    'valium': 'diazepam',
    'ativan': 'lorazepam',
    'klonopin': 'clonazepam',

    // SSRIs
    'prozac': 'fluoxetine',
    'sarafem': 'fluoxetine',
    'zoloft': 'sertraline',
    'lexapro': 'escitalopram',
    'celexa': 'citalopram',
    'paxil': 'paroxetine',

    // Immunosuppressants
    'rheumatrex': 'methotrexate',
    'trexall': 'methotrexate',

    // Mood Stabilisers
    'eskalith': 'lithium',
    'lithobid': 'lithium',

    // Calcium supplements
    'caltrate': 'calcium carbonate',
    'os-cal': 'calcium carbonate',
    'tums': 'calcium carbonate',

    // Antacids
    'maalox': 'antacid',
    'mylanta': 'antacid',
    'rolaids': 'antacid',
    'gaviscon': 'antacid',
  };

  // ── Load & cache JSON ─────────────────────────────────────────────────────

  Future<List<InteractionEntry>> _loadEntries() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await rootBundle.loadString(
        'assets/interactions/known_interactions.json',
      );
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => InteractionEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _cache = list;
      return list;
    } catch (_) {
      _cache = [];
      return [];
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  @override
  String normalizeToIngredient(String medicationName) {
    final lower = medicationName.toLowerCase().trim();

    // Exact match first.
    if (_ingredientMap.containsKey(lower)) {
      return _ingredientMap[lower]!;
    }

    // Substring match (handles e.g. "Advil 200mg" → "ibuprofen").
    for (final entry in _ingredientMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    // Strip common dosage suffixes (digits + units).
    final cleaned = lower
        .replaceAll(RegExp(r'\d+\s*(mg|ml|mcg|g|%|iu)\b'), '')
        .trim();
    if (cleaned.isNotEmpty && cleaned != lower) {
      return normalizeToIngredient(cleaned);
    }

    return lower; // Return the lowercased name as a fallback.
  }

  @override
  Future<List<DrugInteraction>> checkInteractions(
    List<Medication> medications,
  ) async {
    if (medications.length < 2) return [];

    final entries = await _loadEntries();
    final results = <DrugInteraction>[];
    final seen = <String>{};

    // Check every unique pair.
    for (int i = 0; i < medications.length; i++) {
      for (int j = i + 1; j < medications.length; j++) {
        final medA = medications[i];
        final medB = medications[j];

        final ingA = normalizeToIngredient(medA.name);
        final ingB = normalizeToIngredient(medB.name);

        // Deduplicate (same ingredient under different brand names).
        if (ingA == ingB) continue;

        for (final entry in entries) {
          final matches =
              (_matchesIngredient(ingA, entry.ingredientA) &&
                  _matchesIngredient(ingB, entry.ingredientB)) ||
              (_matchesIngredient(ingA, entry.ingredientB) &&
                  _matchesIngredient(ingB, entry.ingredientA));

          if (!matches) continue;

          // Stable pair key to avoid reporting A↔B and B↔A duplicates.
          final pairIds = [medA.id, medB.id]..sort();
          final pairIngredients = [entry.ingredientA, entry.ingredientB]..sort();
          final key =
              '${pairIds[0]}__${pairIds[1]}__${pairIngredients[0]}__${pairIngredients[1]}';

          if (seen.contains(key)) continue;
          seen.add(key);

          results.add(DrugInteraction(
            medicationAId: medA.id,
            medicationAName: medA.name,
            medicationBId: medB.id,
            medicationBName: medB.name,
            ingredientA: entry.ingredientA,
            ingredientB: entry.ingredientB,
            severity: entry.severity,
            summary: entry.summary,
            mechanism: entry.mechanism,
          ));
        }
      }
    }

    // Surface most severe interactions first.
    results.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return results;
  }

  /// Returns true if [name] matches [pattern] with substring tolerance.
  bool _matchesIngredient(String name, String pattern) {
    // Exact match.
    if (name == pattern) return true;
    // Substring containment (handles generic class tags like "ssri").
    if (name.contains(pattern) || pattern.contains(name)) return true;
    return false;
  }
}
