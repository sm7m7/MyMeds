import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/cabinet/presentation/screens/medication_form_screen.dart';
import 'package:my_meds/features/cabinet/presentation/widgets/medication_photo.dart';
import 'package:my_meds/features/cabinet/presentation/widgets/medication_status_badge.dart';

/// Detail screen displaying full inventory, schedule, and safety details for a cabinet item.
class CabinetDetailScreen extends ConsumerWidget {
  const CabinetDetailScreen({
    required this.medication,
    super.key,
  });

  final Medication medication;

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 40),
        title: const Text('Remove Medication?'),
        content: Text(
          'Are you sure you want to remove "${medication.name}" from your medicine cabinet?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(cabinetControllerProvider.notifier)
          .deleteMedication(medication.id);

      if (context.mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${medication.name} removed from cabinet.'),
            ),
          );
        } else {
          final errorState = ref.read(cabinetControllerProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorState.error?.toString() ?? 'Failed to delete medication.',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allStatuses = medication.getAllStatuses();
    final dateFormat = DateFormat.yMMMMd();
    final daysRemaining = medication.daysUntilExpiration();

    return Scaffold(
      appBar: AppBar(
        title: Text(medication.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Medication',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      MedicationFormScreen(medicationToEdit: medication),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Medication',
            onPressed: () => _handleDelete(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MedicalDisclaimer(),
              const SizedBox(height: 16),

              // Overview Hero Card
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo (or icon fallback)
                          MedicationPhotoView(
                            photoBase64: medication.photoBase64,
                            size: 88,
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
                                const SizedBox(height: 4),
                                Text(
                                  '${medication.dosage} • ${medication.form.displayName}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allStatuses.map((st) {
                          return MedicationStatusBadge(status: st);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Inventory Card with Quick Dose Stepper
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Current Inventory',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${medication.quantity} doses',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: medication.isLowStock
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            onPressed: medication.quantity > 0
                                ? () => ref
                                .read(cabinetControllerProvider.notifier)
                                .adjustQuantity(medication, -1)
                                : null,
                            icon: const Icon(Icons.remove),
                            label: const Text('Log 1 Dose Taken'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => ref
                                .read(cabinetControllerProvider.notifier)
                                .adjustQuantity(medication, 10),
                            icon: const Icon(Icons.add),
                            label: const Text('+10 Refill'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Expiration & Storage Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.event_outlined,
                          color: medication.isExpired()
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                        title: const Text('Expiration Date'),
                        subtitle: Text(
                          medication.isExpired()
                              ? 'Expired on ${dateFormat.format(medication.expirationDate)} ($daysRemaining days ago)'
                              : '${dateFormat.format(medication.expirationDate)} ($daysRemaining days remaining)',
                          style: TextStyle(
                            color: medication.isExpired()
                                ? theme.colorScheme.error
                                : null,
                            fontWeight: medication.isExpired()
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (medication.storageConditions != null &&
                          medication.storageConditions!.isNotEmpty) ...[
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.thermostat_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Storage Conditions'),
                          subtitle: Text(medication.storageConditions!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Card
              if (medication.notes != null &&
                  medication.notes!.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notes_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Notes & Instructions',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          medication.notes!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}