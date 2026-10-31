import 'package:flutter/material.dart';
import 'package:my_meds/features/interactions/domain/models/drug_interaction.dart';

/// Reusable modal dialog shown when a drug interaction is detected.
///
/// Severity, plain-language summary, and the mandatory "Consult a doctor or
/// pharmacist" call-to-action are all shown.
class InteractionWarningDialog extends StatelessWidget {
  const InteractionWarningDialog({
    required this.interactions,
    required this.newMedicationName,
    super.key,
  });

  final List<DrugInteraction> interactions;
  final String newMedicationName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sort so the most severe comes first.
    final sorted = [...interactions]
      ..sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
      title: const Text(
        'Possible Drug Interactions',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disclaimer banner
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Informational only. Consult a doctor or pharmacist before '
                      'making any changes to your medications.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              '$newMedicationName may interact with:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...sorted.map((interaction) {
              final other = interaction.medicationAName == newMedicationName
                  ? interaction.medicationBName
                  : interaction.medicationAName;
              return _InteractionCard(
                otherMedicationName: other,
                interaction: interaction,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Save Anyway'),
        ),
      ],
    );
  }

  /// Shows the dialog and returns `true` if the user decides to save anyway,
  /// `false` or `null` if they cancel.
  static Future<bool> show({
    required BuildContext context,
    required List<DrugInteraction> interactions,
    required String newMedicationName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InteractionWarningDialog(
        interactions: interactions,
        newMedicationName: newMedicationName,
      ),
    );
    return result ?? false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private card widget
// ─────────────────────────────────────────────────────────────────────────────

class _InteractionCard extends StatelessWidget {
  const _InteractionCard({
    required this.otherMedicationName,
    required this.interaction,
  });

  final String otherMedicationName;
  final DrugInteraction interaction;

  Color _severityColor(BuildContext context) {
    switch (interaction.severity) {
      case InteractionSeverity.contraindicated:
        return Colors.red.shade700;
      case InteractionSeverity.major:
        return Colors.orange.shade800;
      case InteractionSeverity.moderate:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _severityColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medication_rounded, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  otherMedicationName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withAlpha(100)),
                ),
                child: Text(
                  interaction.severity.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            interaction.summary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (interaction.mechanism.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Mechanism: ${interaction.mechanism}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
