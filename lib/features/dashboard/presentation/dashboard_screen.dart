import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/core/router/router.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/cabinet/presentation/widgets/attention_needed_section.dart';
import 'package:my_meds/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:my_meds/features/reminders/presentation/widgets/dose_occurrence_card.dart';
import 'package:my_meds/features/settings/presentation/providers/inventory_settings_providers.dart';

/// Health Dashboard screen providing high-level inventory analytics, attention-needed items,
/// and today's dose schedule.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final medicationsAsync = ref.watch(cabinetMedicationsStreamProvider);
    final todayOccurrencesAsync = ref.watch(todayOccurrencesProvider);
    final stockService = ref.watch(stockExpirationServiceProvider);
    final settings = ref.watch(inventorySettingsProvider);

    final medications = medicationsAsync.valueOrNull ?? [];
    final expiredCount = stockService.filterExpired(medications, settings: settings).length;
    final expiringCount = stockService.filterExpiringSoon(medications, settings: settings).length;
    final lowStockCount = stockService.filterLowStock(medications, settings: settings).length;
    final totalMeds = medications.length;

    final todayStr = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings & Thresholds',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cabinetMedicationsStreamProvider);
          ref.invalidate(todayDoseLogsStreamProvider);
          ref.invalidate(userRemindersStreamProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: MedicalDisclaimer(),
            ),

            // Date & Welcome header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todayStr,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Health & Medication Summary',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Metric Stat Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          theme: theme,
                          icon: Icons.inventory_2_outlined,
                          label: 'Total Items',
                          value: '$totalMeds',
                          color: theme.colorScheme.primary,
                          bgColor: theme.colorScheme.primaryContainer.withAlpha(80),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          theme: theme,
                          icon: Icons.cancel_outlined,
                          label: 'Expired',
                          value: '$expiredCount',
                          color: Colors.red.shade800,
                          bgColor: Colors.red.shade50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          theme: theme,
                          icon: Icons.hourglass_bottom_rounded,
                          label: 'Expiring Soon',
                          value: '$expiringCount',
                          color: Colors.amber.shade900,
                          bgColor: Colors.amber.shade50,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          theme: theme,
                          icon: Icons.production_quantity_limits_rounded,
                          label: 'Low Stock',
                          value: '$lowStockCount',
                          color: Colors.deepPurple.shade700,
                          bgColor: Colors.deepPurple.shade50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Attention Needed Section (Expired, Expiring Soon, Low Stock)
            const AttentionNeededSection(showHeader: true),

            const SizedBox(height: 12),

            // Today's Doses Header & Preview
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.alarm_rounded, color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Today's Medication Schedule",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.reminders),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            todayOccurrencesAsync.when(
              data: (occurrences) {
                if (occurrences.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      color: theme.colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text('No doses scheduled for today.'),
                        ),
                      ),
                    ),
                  );
                }

                // Show first 3 occurrences on dashboard
                final displayOccurrences = occurrences.take(3).toList();
                return Column(
                  children: displayOccurrences.map((occurrence) {
                    return DoseOccurrenceCard(occurrence: occurrence);
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading schedule: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
