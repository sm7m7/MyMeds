import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_meds/core/router/router.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_status.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/cabinet/presentation/screens/cabinet_detail_screen.dart';
import 'package:my_meds/features/cabinet/presentation/screens/medication_form_screen.dart';
import 'package:my_meds/features/cabinet/presentation/widgets/cabinet_medication_tile.dart';

/// Digital Medicine Cabinet screen showing all user medications with real-time sync, search, and filters.
class CabinetScreen extends ConsumerStatefulWidget {
  const CabinetScreen({super.key});

  @override
  ConsumerState<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends ConsumerState<CabinetScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddMedication() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MedicationFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicationsAsync = ref.watch(cabinetMedicationsStreamProvider);
    final filteredMedications = ref.watch(filteredCabinetMedicationsProvider);
    final selectedForm = ref.watch(cabinetFormFilterProvider);
    final selectedStatus = ref.watch(cabinetStatusFilterProvider);
    final allMedications = medicationsAsync.valueOrNull ?? [];

    // Calculate summary statistics
    final expiredCount = allMedications.where((m) => m.isExpired()).length;
    final expiringCount =
        allMedications.where((m) => m.isExpiringSoon()).length;
    final lowStockCount = allMedications.where((m) => m.isLowStock).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medicine Cabinet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Medication',
            onPressed: _openAddMedication,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMedication,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Medication'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mandatory Medical Disclaimer
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: MedicalDisclaimer(),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search cabinet medications...',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(cabinetSearchQueryProvider.notifier).state = '';
                      },
                    ),
                ],
                onChanged: (val) {
                  ref.read(cabinetSearchQueryProvider.notifier).state = val;
                },
              ),
            ),

            // Quick Status Summary Bar (if medications exist)
            if (allMedications.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    // Total
                    _buildSummaryBadge(
                      label: 'Total: ${allMedications.length}',
                      color: theme.colorScheme.primary,
                      isSelected: selectedStatus == null && selectedForm == null,
                      onTap: () {
                        ref.read(cabinetStatusFilterProvider.notifier).state =
                            null;
                        ref.read(cabinetFormFilterProvider.notifier).state =
                            null;
                      },
                    ),
                    const SizedBox(width: 8),
                    // Expired badge
                    if (expiredCount > 0) ...[
                      _buildSummaryBadge(
                        label: '$expiredCount Expired',
                        color: Colors.red[700]!,
                        isSelected: selectedStatus == MedicationStatus.expired,
                        onTap: () {
                          ref.read(cabinetStatusFilterProvider.notifier).state =
                              selectedStatus == MedicationStatus.expired
                                  ? null
                                  : MedicationStatus.expired;
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Expiring Soon badge
                    if (expiringCount > 0) ...[
                      _buildSummaryBadge(
                        label: '$expiringCount Expiring Soon',
                        color: Colors.orange[800]!,
                        isSelected:
                            selectedStatus == MedicationStatus.expiringSoon,
                        onTap: () {
                          ref.read(cabinetStatusFilterProvider.notifier).state =
                              selectedStatus == MedicationStatus.expiringSoon
                                  ? null
                                  : MedicationStatus.expiringSoon;
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Low Stock badge
                    if (lowStockCount > 0) ...[
                      _buildSummaryBadge(
                        label: '$lowStockCount Low Stock',
                        color: Colors.blue[800]!,
                        isSelected: selectedStatus == MedicationStatus.lowStock,
                        onTap: () {
                          ref.read(cabinetStatusFilterProvider.notifier).state =
                              selectedStatus == MedicationStatus.lowStock
                                  ? null
                                  : MedicationStatus.lowStock;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Form Filter Chips (Tablet, Capsule, Syrup, etc.)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Forms'),
                    selected: selectedForm == null,
                    onSelected: (_) {
                      ref.read(cabinetFormFilterProvider.notifier).state = null;
                    },
                  ),
                  const SizedBox(width: 6),
                  ...MedicationForm.values.map((form) {
                    final isSelected = selectedForm == form;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(form.displayName),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(cabinetFormFilterProvider.notifier).state =
                              isSelected ? null : form;
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Medication List View
            Expanded(
              child: medicationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text('Failed to load medicine cabinet: $err'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              ref.refresh(cabinetMedicationsStreamProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (_) {
                  if (allMedications.isEmpty) {
                    return _buildEmptyCabinetState(theme);
                  }

                  if (filteredMedications.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_alt_off_outlined,
                              size: 48,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No medications match your filter.',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                ref.read(cabinetSearchQueryProvider.notifier).state = '';
                                ref.read(cabinetFormFilterProvider.notifier).state = null;
                                ref.read(cabinetStatusFilterProvider.notifier).state = null;
                              },
                              child: const Text('Reset filters'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredMedications.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final med = filteredMedications[index];
                      return CabinetMedicationTile(
                        medication: med,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CabinetDetailScreen(medication: med),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBadge({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCabinetState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services_outlined,
                size: 56,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cabinet is Empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your active prescriptions, over-the-counter medications, doses, and expiry dates.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _openAddMedication,
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.search),
              icon: const Icon(Icons.search),
              label: const Text('Search Drug Database'),
            ),
          ],
        ),
      ),
    );
  }
}
