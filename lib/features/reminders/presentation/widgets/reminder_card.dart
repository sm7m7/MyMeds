import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';
import 'package:my_meds/features/reminders/presentation/providers/reminders_providers.dart';

/// Card displaying a configured reminder rule with active switch and action menu.
class ReminderCard extends ConsumerWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onEdit,
  });

  final MedicationReminder reminder;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: reminder.isActive
              ? theme.colorScheme.outlineVariant
              : theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      color: reminder.isActive
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: reminder.isActive
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.alarm_rounded,
                    color: reminder.isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.medicationName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: reminder.isActive
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        'Dose: ${reminder.dosage}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (val) {
                    ref
                        .read(reminderCrudControllerProvider.notifier)
                        .toggleActive(reminder, val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Frequency description
            Row(
              children: [
                Icon(
                  Icons.repeat_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  reminder.frequencyDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Times chips
            if (reminder.times.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: reminder.times.map((t) {
                  return Chip(
                    label: Text(t),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  );
                }).toList(),
              ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Started: ${dateFormat.format(reminder.startDate)}${reminder.durationDays != null ? ' (${reminder.durationDays} days)' : ' (Ongoing)'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit reminder',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: 'Delete reminder',
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text(
          'Are you sure you want to delete the reminder for "${reminder.medicationName}"? All scheduled notifications will be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(reminderCrudControllerProvider.notifier)
                  .deleteReminder(reminder.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
