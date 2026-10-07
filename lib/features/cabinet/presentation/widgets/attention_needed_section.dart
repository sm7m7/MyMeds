import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_status.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/cabinet/presentation/screens/cabinet_detail_screen.dart';
import 'package:my_meds/features/settings/presentation/providers/inventory_settings_providers.dart';

/// Interactive section displaying medications that require user attention
/// (expired, expiring soon, low stock) with quick actions to restock or dispose.
class AttentionNeededSection extends ConsumerWidget {
  const AttentionNeededSection({
    super.key,
    this.showHeader = true,
  });

  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final attentionMedications = ref.watch(attentionNeededMedicationsProvider);
    final stockService = ref.watch(stockExpirationServiceProvider);
    final settings = ref.watch(inventorySettingsProvider);

    if (attentionMedications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade800,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Attention Needed (${attentionMedications.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: attentionMedications.length,
          itemBuilder: (context, index) {
            final med = attentionMedications[index];
            final status = stockService.classifyMedication(
              med,
              settings: settings,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: _getBorderColor(status.primaryStatus, theme),
                  width: 1.2,
                ),
              ),
              color: _getCardBgColor(status.primaryStatus, theme),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CabinetDetailScreen(medication: med),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusIcon(status.primaryStatus, theme),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Dose: ${med.dosage} • Quantity: ${med.quantity}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (status.attentionReason != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    status.attentionReason!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getTextColor(status.primaryStatus),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Quick Restock / Quantity Update Button
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.edit_note_rounded, size: 16),
                            label: const Text('Update Qty'),
                            onPressed: () => _showUpdateQuantityDialog(
                              context,
                              ref,
                              med,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quick Mark Disposed / Delete Button
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: Colors.red.shade900,
                              backgroundColor: Colors.red.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(
                              Icons.delete_sweep_outlined,
                              size: 16,
                            ),
                            label: Text(
                              status.isExpired ? 'Dispose' : 'Remove',
                            ),
                            onPressed: () => _confirmDispose(
                              context,
                              ref,
                              med,
                              status.isExpired,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusIcon(MedicationStatus status, ThemeData theme) {
    switch (status) {
      case MedicationStatus.expired:
        return CircleAvatar(
          radius: 18,
          backgroundColor: Colors.red.shade100,
          child: Icon(
            Icons.cancel_outlined,
            color: Colors.red.shade800,
            size: 20,
          ),
        );
      case MedicationStatus.expiringSoon:
        return CircleAvatar(
          radius: 18,
          backgroundColor: Colors.amber.shade100,
          child: Icon(
            Icons.hourglass_bottom_rounded,
            color: Colors.amber.shade900,
            size: 20,
          ),
        );
      case MedicationStatus.lowStock:
        return CircleAvatar(
          radius: 18,
          backgroundColor: Colors.deepPurple.shade50,
          child: Icon(
            Icons.inventory_2_outlined,
            color: Colors.deepPurple.shade700,
            size: 20,
          ),
        );
      case MedicationStatus.ok:
        return CircleAvatar(
          radius: 18,
          backgroundColor: Colors.green.shade50,
          child: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 20,
          ),
        );
    }
  }

  Color _getBorderColor(MedicationStatus status, ThemeData theme) {
    switch (status) {
      case MedicationStatus.expired:
        return Colors.red.shade300;
      case MedicationStatus.expiringSoon:
        return Colors.amber.shade400;
      case MedicationStatus.lowStock:
        return Colors.deepPurple.shade200;
      case MedicationStatus.ok:
        return theme.colorScheme.outlineVariant;
    }
  }

  Color _getCardBgColor(MedicationStatus status, ThemeData theme) {
    switch (status) {
      case MedicationStatus.expired:
        return Colors.red.withAlpha(12);
      case MedicationStatus.expiringSoon:
        return Colors.amber.withAlpha(12);
      case MedicationStatus.lowStock:
        return Colors.deepPurple.withAlpha(10);
      case MedicationStatus.ok:
        return theme.colorScheme.surface;
    }
  }

  Color _getTextColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.expired:
        return Colors.red.shade800;
      case MedicationStatus.expiringSoon:
        return Colors.amber.shade900;
      case MedicationStatus.lowStock:
        return Colors.deepPurple.shade800;
      case MedicationStatus.ok:
        return Colors.green.shade800;
    }
  }

  void _showUpdateQuantityDialog(
    BuildContext context,
    WidgetRef ref,
    Medication medication,
  ) {
    int currentQty = medication.quantity;
    final textController = TextEditingController(text: currentQty.toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Text('Update Quantity: ${medication.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Stock: $currentQty units',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: currentQty > 0
                          ? () {
                              setState(() {
                                currentQty--;
                                textController.text = currentQty.toString();
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: textController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed >= 0) {
                            setState(() {
                              currentQty = parsed;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () {
                        setState(() {
                          currentQty++;
                          textController.text = currentQty.toString();
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [10, 20, 30].map((add) {
                    return ActionChip(
                      label: Text('+$add'),
                      onPressed: () {
                        setState(() {
                          currentQty += add;
                          textController.text = currentQty.toString();
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final updated = medication.copyWith(
                    quantity: currentQty,
                    updatedAt: DateTime.now(),
                  );
                  await ref
                      .read(cabinetControllerProvider.notifier)
                      .updateMedication(updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Stock'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDispose(
    BuildContext context,
    WidgetRef ref,
    Medication medication,
    bool isExpired,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isExpired ? 'Dispose Expired Medication?' : 'Remove Medication?'),
        content: Text(
          isExpired
              ? 'Are you disposing of "${medication.name}"? It will be removed from your active medicine cabinet.'
              : 'Remove "${medication.name}" from your medicine cabinet?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(cabinetControllerProvider.notifier)
                  .deleteMedication(medication.id);
            },
            child: Text(isExpired ? 'Mark Disposed' : 'Remove'),
          ),
        ],
      ),
    );
  }
}
