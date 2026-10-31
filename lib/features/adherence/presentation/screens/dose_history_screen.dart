import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/adherence/domain/models/adherence_models.dart';
import 'package:my_meds/features/adherence/presentation/providers/adherence_providers.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/reminders/domain/models/dose_log.dart';

/// Chronological Dose History screen displaying logged doses with status and medication filters.
class DoseHistoryScreen extends ConsumerWidget {
  const DoseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(selectedAdherencePeriodProvider);
    final statusFilter = ref.watch(doseHistoryStatusFilterProvider);
    final medFilter = ref.watch(doseHistoryMedicationFilterProvider);
    final filteredLogsAsync = ref.watch(filteredDoseHistoryProvider);
    final cabinetMedsAsync = ref.watch(cabinetMedicationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dose History'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adherenceLogsRangeProvider);
        },
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: MedicalDisclaimer(),
            ),

            // Time Period & Medication Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Period Selector
                  Expanded(
                    child: SegmentedButton<AdherencePeriod>(
                      segments: const [
                        ButtonSegment(
                          value: AdherencePeriod.week,
                          label: Text('7 Days'),
                        ),
                        ButtonSegment(
                          value: AdherencePeriod.month,
                          label: Text('30 Days'),
                        ),
                      ],
                      selected: {period},
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onSelectionChanged: (set) {
                        ref.read(selectedAdherencePeriodProvider.notifier).state =
                            set.first;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Medication Dropdown Filter
                  cabinetMedsAsync.when(
                    data: (meds) {
                      return DropdownButton<String?>(
                        value: medFilter,
                        hint: const Text('All Meds'),
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.filter_alt_outlined, size: 20),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Meds'),
                          ),
                          ...meds.map((m) => DropdownMenuItem<String?>(
                                value: m.id,
                                child: Text(
                                  m.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                        ],
                        onChanged: (val) {
                          ref
                              .read(doseHistoryMedicationFilterProvider.notifier)
                              .state = val;
                        },
                      );
                    },
                    loading: () => const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Statuses'),
                    selected: statusFilter == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(doseHistoryStatusFilterProvider.notifier).state =
                            null;
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: statusFilter == DoseLogStatus.taken
                        ? null
                        : Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                    label: const Text('Taken'),
                    selected: statusFilter == DoseLogStatus.taken,
                    onSelected: (selected) {
                      ref.read(doseHistoryStatusFilterProvider.notifier).state =
                          selected ? DoseLogStatus.taken : null;
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: statusFilter == DoseLogStatus.missed
                        ? null
                        : Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                    label: const Text('Missed'),
                    selected: statusFilter == DoseLogStatus.missed,
                    onSelected: (selected) {
                      ref.read(doseHistoryStatusFilterProvider.notifier).state =
                          selected ? DoseLogStatus.missed : null;
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: statusFilter == DoseLogStatus.skipped
                        ? null
                        : Icon(Icons.remove_circle, size: 16, color: Colors.grey.shade600),
                    label: const Text('Skipped'),
                    selected: statusFilter == DoseLogStatus.skipped,
                    onSelected: (selected) {
                      ref.read(doseHistoryStatusFilterProvider.notifier).state =
                          selected ? DoseLogStatus.skipped : null;
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // History List
            Expanded(
              child: filteredLogsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 56,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No dose records found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try adjusting the date range or filter options.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return _buildHistoryCard(context, log);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading history: $err'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, DoseLog log) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('MMM d, h:mm a');
    final formattedTime = timeFormat.format(log.scheduledTime);

    final statusColor = _getStatusColor(log.status);
    final statusIcon = _getStatusIcon(log.status);
    final statusLabel = _getStatusLabel(log.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.medicationName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${log.dosage} · $formattedTime',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (log.actualTime != null && log.status == DoseLogStatus.taken)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Logged at ${DateFormat('h:mm a').format(log.actualTime!)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withAlpha(100)),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DoseLogStatus status) {
    switch (status) {
      case DoseLogStatus.taken:
        return Colors.green.shade700;
      case DoseLogStatus.missed:
        return Colors.red.shade700;
      case DoseLogStatus.skipped:
        return Colors.grey.shade600;
      case DoseLogStatus.pending:
        return Colors.blue.shade600;
    }
  }

  IconData _getStatusIcon(DoseLogStatus status) {
    switch (status) {
      case DoseLogStatus.taken:
        return Icons.check_circle_rounded;
      case DoseLogStatus.missed:
        return Icons.cancel_rounded;
      case DoseLogStatus.skipped:
        return Icons.remove_circle_rounded;
      case DoseLogStatus.pending:
        return Icons.schedule_rounded;
    }
  }

  String _getStatusLabel(DoseLogStatus status) {
    switch (status) {
      case DoseLogStatus.taken:
        return 'Taken';
      case DoseLogStatus.missed:
        return 'Missed';
      case DoseLogStatus.skipped:
        return 'Skipped';
      case DoseLogStatus.pending:
        return 'Pending';
    }
  }
}
