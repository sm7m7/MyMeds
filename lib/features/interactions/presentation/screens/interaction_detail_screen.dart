import 'package:flutter/material.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/interactions/domain/models/drug_interaction.dart';

/// Full-detail view for a single drug-drug interaction.
class InteractionDetailScreen extends StatelessWidget {
  const InteractionDetailScreen({required this.interaction, super.key});

  final DrugInteraction interaction;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interaction Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disclaimer
            const MedicalDisclaimer(),
            const SizedBox(height: 20),

            // Severity banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withAlpha(80)),
              ),
              child: Row(
                children: [
                  Icon(_severityIcon(), color: color, size: 32),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interaction.severity.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: color,
                        ),
                      ),
                      Text(
                        'Severity Level',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Medication pair
            _SectionCard(
              title: 'Medications Involved',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MedicationChip(name: interaction.medicationAName),
                  const SizedBox(height: 8),
                  Center(
                    child: Icon(
                      Icons.sync_alt_rounded,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MedicationChip(name: interaction.medicationBName),
                  const SizedBox(height: 10),
                  Text(
                    'Active ingredients: ${interaction.ingredientA} ↔ ${interaction.ingredientB}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Plain-language summary
            _SectionCard(
              title: 'What This Means',
              child: Text(
                interaction.summary,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Mechanism
            if (interaction.mechanism.isNotEmpty)
              _SectionCard(
                title: 'Pharmacological Mechanism',
                child: Text(
                  interaction.mechanism,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Consult CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(80),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Consult a doctor or pharmacist.',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This information is for awareness only. Never stop, start, '
                    'or change a medication without professional guidance.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MedicationChip extends StatelessWidget {
  const _MedicationChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.medication_rounded,
              size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
