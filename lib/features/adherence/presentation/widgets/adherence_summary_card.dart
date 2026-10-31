import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/adherence/domain/models/adherence_models.dart';
import 'package:my_meds/features/adherence/presentation/providers/adherence_providers.dart';

/// Summary card displaying key adherence KPIs: Adherence %, Scheduled, Taken, Missed, Skipped.
class AdherenceSummaryCard extends ConsumerWidget {
  const AdherenceSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(selectedAdherencePeriodProvider);
    final summaryAsync = ref.watch(adherenceSummaryProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Period Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adherence Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SegmentedButton<AdherencePeriod>(
                  segments: const [
                    ButtonSegment(
                      value: AdherencePeriod.week,
                      label: Text('Week'),
                    ),
                    ButtonSegment(
                      value: AdherencePeriod.month,
                      label: Text('Month'),
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
              ],
            ),
            const SizedBox(height: 16),

            summaryAsync.when(
              data: (summary) {
                if (!summary.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.query_stats_rounded,
                            size: 40,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No recorded doses for this period.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Main Rate Card with Circular Indicator
                    Row(
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: summary.adherenceRate / 100.0,
                                strokeWidth: 8,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                color: _getAdherenceColor(summary.adherenceRate),
                              ),
                              Center(
                                child: Text(
                                  summary.formattedRate,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getAdherenceColor(summary.adherenceRate),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getAdherenceMessage(summary.adherenceRate),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${summary.totalTaken} of ${summary.totalScheduled} scheduled doses taken on time.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // Key Metrics Row: Scheduled, Taken, Missed, Skipped
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricPill(
                          label: 'Scheduled',
                          count: summary.totalScheduled,
                          color: theme.colorScheme.primary,
                          icon: Icons.calendar_today_rounded,
                        ),
                        _buildMetricPill(
                          label: 'Taken',
                          count: summary.totalTaken,
                          color: Colors.green.shade800,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                        _buildMetricPill(
                          label: 'Missed',
                          count: summary.totalMissed,
                          color: Colors.red.shade800,
                          icon: Icons.warning_amber_rounded,
                        ),
                        _buildMetricPill(
                          label: 'Skipped',
                          count: summary.totalSkipped,
                          color: theme.colorScheme.outline,
                          icon: Icons.remove_circle_outline_rounded,
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text('Failed to calculate adherence: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withAlpha(200),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 80) return Colors.green.shade700;
    if (rate >= 60) return Colors.amber.shade800;
    return Colors.red.shade700;
  }

  String _getAdherenceMessage(double rate) {
    if (rate >= 90) return 'Outstanding Adherence! 🌟';
    if (rate >= 80) return 'Great Consistency! 👍';
    if (rate >= 60) return 'Moderate Adherence ⚠️';
    return 'Action Needed — Low Adherence 🚨';
  }
}
