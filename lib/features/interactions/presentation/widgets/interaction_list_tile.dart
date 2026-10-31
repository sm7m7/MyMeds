import 'package:flutter/material.dart';
import 'package:my_meds/features/interactions/domain/models/drug_interaction.dart';

/// A compact card summarizing a single drug-drug interaction.
///
/// Used in the Interactions screen list.
class InteractionListTile extends StatelessWidget {
  const InteractionListTile({
    required this.interaction,
    this.onTap,
    super.key,
  });

  final DrugInteraction interaction;
  final VoidCallback? onTap;

  Color _severityColor() {
    switch (interaction.severity) {
      case InteractionSeverity.contraindicated:
        return Colors.red.shade700;
      case InteractionSeverity.major:
        return Colors.orange.shade800;
      case InteractionSeverity.moderate:
        return Colors.amber.shade800;
    }
  }

  IconData _severityIcon() {
    switch (interaction.severity) {
      case InteractionSeverity.contraindicated:
        return Icons.block_rounded;
      case InteractionSeverity.major:
        return Icons.warning_rounded;
      case InteractionSeverity.moderate:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _severityColor();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withAlpha(60)),
      ),
      color: color.withAlpha(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Severity icon circle
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(_severityIcon(), color: color, size: 22),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medication pair heading
                    Text(
                      '${interaction.medicationAName} + ${interaction.medicationBName}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Ingredient sub-label
                    Text(
                      '(${interaction.ingredientA} ↔ ${interaction.ingredientB})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Summary snippet
                    Text(
                      interaction.summary,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Severity badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        ),
      ),
    );
  }
}
