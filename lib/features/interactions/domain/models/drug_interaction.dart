import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Severity
// ─────────────────────────────────────────────────────────────────────────────

/// Severity levels for drug interactions, from least to most serious.
enum InteractionSeverity {
  moderate,
  major,
  contraindicated;

  /// Human-readable label.
  String get displayName {
    switch (this) {
      case InteractionSeverity.moderate:
        return 'Moderate';
      case InteractionSeverity.major:
        return 'Major';
      case InteractionSeverity.contraindicated:
        return 'Contraindicated';
    }
  }

  /// Short one-word label for badges.
  String get badge {
    switch (this) {
      case InteractionSeverity.moderate:
        return '⚠ Moderate';
      case InteractionSeverity.major:
        return '🚨 Major';
      case InteractionSeverity.contraindicated:
        return '⛔ Contraindicated';
    }
  }

  static InteractionSeverity fromString(String? value) {
    return InteractionSeverity.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => InteractionSeverity.moderate,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drug Interaction
// ─────────────────────────────────────────────────────────────────────────────

/// A detected interaction between two medications in the user's cabinet.
@immutable
class DrugInteraction {
  const DrugInteraction({
    required this.medicationAId,
    required this.medicationAName,
    required this.medicationBId,
    required this.medicationBName,
    required this.ingredientA,
    required this.ingredientB,
    required this.severity,
    required this.summary,
    required this.mechanism,
  });

  final String medicationAId;
  final String medicationAName;
  final String medicationBId;
  final String medicationBName;

  /// Normalized active ingredient for drug A.
  final String ingredientA;

  /// Normalized active ingredient for drug B.
  final String ingredientB;

  final InteractionSeverity severity;

  /// Plain-language explanation suitable for a patient.
  final String summary;

  /// Pharmacological mechanism (informational, non-diagnostic).
  final String mechanism;

  /// A stable ID for this pair (order-independent).
  String get pairKey {
    final sorted = [medicationAId, medicationBId]..sort();
    return '${sorted[0]}__${sorted[1]}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrugInteraction &&
          runtimeType == other.runtimeType &&
          pairKey == other.pairKey;

  @override
  int get hashCode => pairKey.hashCode;
}

// ─────────────────────────────────────────────────────────────────────────────
// Interaction Entry  (raw from JSON)
// ─────────────────────────────────────────────────────────────────────────────

/// Raw entry from the local interactions JSON bundle.
@immutable
class InteractionEntry {
  const InteractionEntry({
    required this.ingredientA,
    required this.ingredientB,
    required this.severity,
    required this.summary,
    required this.mechanism,
  });

  final String ingredientA;
  final String ingredientB;
  final InteractionSeverity severity;
  final String summary;
  final String mechanism;

  factory InteractionEntry.fromJson(Map<String, dynamic> json) {
    return InteractionEntry(
      ingredientA: (json['ingredient_a'] as String? ?? '').toLowerCase().trim(),
      ingredientB: (json['ingredient_b'] as String? ?? '').toLowerCase().trim(),
      severity: InteractionSeverity.fromString(json['severity'] as String?),
      summary: json['summary'] as String? ?? '',
      mechanism: json['mechanism'] as String? ?? '',
    );
  }
}
