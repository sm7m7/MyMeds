import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/core/theme/theme.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/adherence/presentation/providers/adherence_providers.dart';
import 'package:my_meds/features/adherence/presentation/widgets/adherence_bar_chart.dart';
import 'package:my_meds/features/adherence/presentation/widgets/adherence_summary_card.dart';
import 'package:my_meds/features/adherence/presentation/widgets/per_medication_adherence_list.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/cabinet/presentation/widgets/attention_needed_section.dart';
import 'package:my_meds/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:my_meds/features/settings/presentation/providers/inventory_settings_providers.dart';

/// Health Dashboard screen providing adherence analytics, inventory status,
/// and attention-needed items.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final medicationsAsync = ref.watch(cabinetMedicationsStreamProvider);
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

      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cabinetMedicationsStreamProvider);
          ref.invalidate(todayDoseLogsStreamProvider);
          ref.invalidate(userRemindersStreamProvider);
          ref.invalidate(adherenceLogsRangeProvider);
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
                          color: AppColors.blue,
                          bgColor: AppColors.sky.withValues(alpha: 0.20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          theme: theme,
                          icon: Icons.cancel_outlined,
                          label: 'Expired',
                          value: '$expiredCount',
                          color: AppColors.navy,
                          bgColor: AppColors.sky.withValues(alpha: 0.20),
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
                          color: AppColors.navy,
                          bgColor: AppColors.cyan.withValues(alpha: 0.15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          theme: theme,
                          icon: Icons.production_quantity_limits_rounded,
                          label: 'Low Stock',
                          value: '$lowStockCount',
                          color: AppColors.blue,
                          bgColor: AppColors.cyan.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Adherence Analytics Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Medication Adherence',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AdherenceSummaryCard(),
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AdherenceBarChart(),
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PerMedicationAdherenceList(),
            ),

            const SizedBox(height: 16),

            // Attention Needed Section (Expired, Expiring Soon, Low Stock)
            const AttentionNeededSection(showHeader: true),
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