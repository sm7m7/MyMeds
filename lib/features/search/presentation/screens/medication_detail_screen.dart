import 'package:flutter/material.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/search/domain/medication_info.dart';
import 'package:my_meds/features/search/presentation/widgets/add_to_cabinet_modal.dart';

/// Screen displaying comprehensive drug monograph and clinical label details.
class MedicationDetailScreen extends StatelessWidget {
  const MedicationDetailScreen({
    required this.medication,
    super.key,
  });

  final MedicationInfo medication;

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String? content,
    Color? headerColor,
    bool isWarning = false,
  }) {
    if (content == null || content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isWarning
          ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
          : theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isWarning
                      ? theme.colorScheme.error
                      : (headerColor ?? theme.colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isWarning
                          ? theme.colorScheme.error
                          : (headerColor ?? theme.colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              content.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(medication.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Add to Cabinet',
            onPressed: () => AddToCabinetModal.show(context, medication),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mandatory medical disclaimer
              const MedicalDisclaimer(),
              const SizedBox(height: 16),

              // Medication Header Card
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.medication_rounded,
                              size: 32,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medication.name,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                if (medication.genericName != null &&
                                    medication.genericName!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    medication.genericName!,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: theme
                                          .colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (medication.activeIngredients.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: medication.activeIngredients.map((ingredient) {
                            return Chip(
                              label: Text(
                                ingredient,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: theme.colorScheme.surface,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // High priority: Boxed Warning (Black Box)
              if (medication.boxedWarning != null)
                _buildSectionCard(
                  context: context,
                  title: 'BOXED WARNING',
                  icon: Icons.warning_rounded,
                  content: medication.boxedWarning,
                  isWarning: true,
                ),

              // Purpose / Indication
              _buildSectionCard(
                context: context,
                title: 'Purpose & Indication',
                icon: Icons.healing_outlined,
                content: medication.purpose ?? medication.indicationsAndUsage,
              ),

              // Indications & Usage (if separate from purpose)
              if (medication.purpose != null &&
                  medication.indicationsAndUsage != null &&
                  medication.indicationsAndUsage != medication.purpose)
                _buildSectionCard(
                  context: context,
                  title: 'Indications & Usage',
                  icon: Icons.assignment_outlined,
                  content: medication.indicationsAndUsage,
                ),

              // Dosage Information
              _buildSectionCard(
                context: context,
                title: 'Dosage & Administration',
                icon: Icons.access_time_filled_outlined,
                content: medication.dosageAndAdministration,
              ),

              // Storage Conditions
              _buildSectionCard(
                context: context,
                title: 'Storage & Handling',
                icon: Icons.thermostat_outlined,
                content: medication.storageAndHandling,
              ),

              // Warnings & Precautions
              _buildSectionCard(
                context: context,
                title: 'Warnings & Precautions',
                icon: Icons.report_problem_outlined,
                content: medication.warnings,
                isWarning: true,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: () => AddToCabinetModal.show(context, medication),
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: const Text(
            'Add to My Cabinet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
