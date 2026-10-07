import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/features/reminders/domain/models/dose_log.dart';
import 'package:my_meds/features/reminders/presentation/providers/reminders_providers.dart';

/// Card widget displaying a single scheduled dose occurrence with quick actions.
class DoseOccurrenceCard extends ConsumerWidget {
  const DoseOccurrenceCard({
    super.key,
    required this.occurrence,
  });

  final DoseOccurrence occurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('hh:mm a');
    final formattedTime = timeFormat.format(occurrence.scheduledTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getBorderColor(theme),
          width: occurrence.isPending ? 1.5 : 1,
        ),
      ),
      color: _getBackgroundColor(theme),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Time badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTimeBadgeColor(theme),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: _getTimeTextColor(theme),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedTime,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _getTimeTextColor(theme),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Status badge
                _buildStatusChip(theme),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.medication_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        occurrence.reminder.medicationName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dose: ${occurrence.reminder.dosage}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (occurrence.doseLog?.actualTime != null) ...[
              const SizedBox(height: 8),
              Text(
                '${occurrence.isTaken ? 'Taken' : 'Skipped'} at ${timeFormat.format(occurrence.doseLog!.actualTime!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 14),
            // Quick action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: occurrence.isTaken
                          ? Colors.green.shade700
                          : theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      ref.read(doseActionControllerProvider.notifier).markDose(
                            occurrence: occurrence,
                            status: DoseLogStatus.taken,
                          );
                    },
                    icon: Icon(
                      occurrence.isTaken ? Icons.check_circle : Icons.check,
                      size: 18,
                    ),
                    label: Text(occurrence.isTaken ? 'Taken' : 'Mark Taken'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: occurrence.isSkipped
                        ? theme.colorScheme.outline
                        : theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    ref.read(doseActionControllerProvider.notifier).markDose(
                          occurrence: occurrence,
                          status: DoseLogStatus.skipped,
                        );
                  },
                  icon: Icon(
                    occurrence.isSkipped
                        ? Icons.remove_circle_outline
                        : Icons.close_rounded,
                    size: 18,
                  ),
                  label: Text(occurrence.isSkipped ? 'Skipped' : 'Skip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String label;

    switch (occurrence.computedStatus) {
      case DoseLogStatus.taken:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle_outline_rounded;
        label = 'Taken';
        break;
      case DoseLogStatus.skipped:
        bgColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.outline;
        icon = Icons.cancel_outlined;
        label = 'Skipped';
        break;
      case DoseLogStatus.missed:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        icon = Icons.warning_amber_rounded;
        label = 'Missed';
        break;
      case DoseLogStatus.pending:
        bgColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        icon = Icons.schedule_rounded;
        label = 'Upcoming';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (occurrence.isTaken) return theme.colorScheme.surface;
    if (occurrence.isMissed) return Colors.red.withAlpha(15);
    return theme.colorScheme.surface;
  }

  Color _getBorderColor(ThemeData theme) {
    if (occurrence.isTaken) return Colors.green.shade300;
    if (occurrence.isMissed) return Colors.red.shade300;
    if (occurrence.isPending) return theme.colorScheme.primary.withAlpha(120);
    return theme.colorScheme.outlineVariant;
  }

  Color _getTimeBadgeColor(ThemeData theme) {
    if (occurrence.isTaken) return Colors.green.shade100;
    if (occurrence.isMissed) return Colors.red.shade100;
    return theme.colorScheme.primaryContainer;
  }

  Color _getTimeTextColor(ThemeData theme) {
    if (occurrence.isTaken) return Colors.green.shade900;
    if (occurrence.isMissed) return Colors.red.shade900;
    return theme.colorScheme.onPrimaryContainer;
  }
}
