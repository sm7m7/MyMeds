import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/adherence/presentation/providers/adherence_providers.dart';

/// Accessible and interactive Bar Chart displaying day-by-day medication adherence breakdown.
class AdherenceBarChart extends ConsumerWidget {
  const AdherenceBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dailyListAsync = ref.watch(dailyAdherenceListProvider);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Intake Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.bar_chart_rounded,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            dailyListAsync.when(
              data: (dailyList) {
                if (dailyList.isEmpty || dailyList.every((d) => d.scheduled == 0)) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No dose activity logged for these days.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  );
                }

                // Compute maximum Y height
                int maxVal = 1;
                for (final d in dailyList) {
                  maxVal = math.max(maxVal, math.max(d.taken, math.max(d.missed, d.skipped)));
                }
                final double maxY = (maxVal + 1).toDouble();

                return Column(
                  children: [
                    SizedBox(
                      height: 190,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Colors.blueGrey.shade900,
                              tooltipRoundedRadius: 8,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final item = dailyList[group.x.toInt()];
                                final statusLabel = rodIndex == 0
                                    ? 'Taken'
                                    : (rodIndex == 1 ? 'Missed' : 'Skipped');
                                return BarTooltipItem(
                                  '${item.dayLabel}\n$statusLabel: ${rod.toY.toInt()}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < dailyList.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        dailyList[index].dayLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: maxY > 6 ? 2 : 1,
                                getTitlesWidget: (value, meta) {
                                  if (value % 1 == 0) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: theme.colorScheme.outline,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: theme.colorScheme.outlineVariant.withAlpha(50),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(dailyList.length, (i) {
                            final day = dailyList[i];
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                // Taken rod (Green)
                                BarChartRodData(
                                  toY: day.taken.toDouble(),
                                  color: Colors.green.shade600,
                                  width: 8,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                                // Missed rod (Red)
                                BarChartRodData(
                                  toY: day.missed.toDouble(),
                                  color: Colors.red.shade600,
                                  width: 8,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                                // Skipped rod (Grey)
                                BarChartRodData(
                                  toY: day.skipped.toDouble(),
                                  color: Colors.grey.shade500,
                                  width: 8,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Accessible Chart Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(Colors.green.shade600, 'Taken'),
                        const SizedBox(width: 16),
                        _buildLegendItem(Colors.red.shade600, 'Missed'),
                        const SizedBox(width: 16),
                        _buildLegendItem(Colors.grey.shade500, 'Skipped'),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text('Error loading chart: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
