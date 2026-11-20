import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_meds/core/router/router.dart';
import 'package:my_meds/core/theme/theme.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/settings/data/demo_data_seeder.dart';
import 'package:my_meds/features/settings/data/locale_repository.dart';
import 'package:my_meds/features/settings/presentation/providers/inventory_settings_providers.dart';
import 'package:my_meds/features/settings/presentation/providers/locale_providers.dart';
import 'package:my_meds/features/settings/presentation/widgets/language_picker_sheet.dart';
import 'package:my_meds/l10n/app_localizations.dart';

/// Settings and account management screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleSignOut(
      BuildContext context,
      WidgetRef ref,
      AppLocalizations l10n,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  Future<void> _handleDeleteAccount(
      BuildContext context,
      WidgetRef ref,
      AppLocalizations l10n,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deletePermanently),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (!success && context.mounted) {
        final errorState = ref.read(authControllerProvider);
        final msg = errorState.error?.toString() ?? l10n.errorGeneric;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final currentLocale = ref.watch(localeProvider);

    // Display name for the currently selected language.
    final langCode = currentLocale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final langName =
        LocaleRepository.localeDisplayNames[langCode] ?? 'English';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const MedicalDisclaimer(),
            const SizedBox(height: 16),

            // ── Profile Card ────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        (user?.email.isNotEmpty == true)
                            ? user!.email[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.email ?? l10n.notLoggedIn,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.uid}: ${user?.uid ?? l10n.notAvailable}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Preferences ─────────────────────────────────────────────────
            _SectionHeader(l10n.settingsPreferences),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(l10n.language),
                    subtitle: Text(langName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => LanguagePickerSheet.show(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: const Text('Dose History'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.doseHistory),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Stock & Expiration ───────────────────────────────────────────
            _SectionHeader(l10n.settingsStockThresholds),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(inventorySettingsProvider);
                final controller =
                ref.read(inventorySettingsProvider.notifier);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        // Expiring Soon Threshold
                        ListTile(
                          leading: const Icon(Icons.hourglass_bottom_rounded),
                          title: Text(l10n.expiringThresholdTitle),
                          subtitle: Text(l10n.expiringThresholdSubtitle(
                              settings.expiringSoonDaysThreshold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(l10n.days7,
                                  style: const TextStyle(fontSize: 12)),
                              Expanded(
                                child: Slider(
                                  value: settings.expiringSoonDaysThreshold
                                      .toDouble(),
                                  min: 7,
                                  max: 90,
                                  divisions: 83,
                                  label:
                                  '${settings.expiringSoonDaysThreshold}d',
                                  onChanged: (val) =>
                                      controller.updateExpiringSoonDays(
                                          val.round()),
                                ),
                              ),
                              Text(l10n.days90,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Low Stock Threshold
                        ListTile(
                          leading: const Icon(
                              Icons.production_quantity_limits_rounded),
                          title: Text(l10n.lowStockThresholdTitle),
                          subtitle: Text(l10n.lowStockThresholdSubtitle(
                              settings.lowStockThreshold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(l10n.unit1,
                                  style: const TextStyle(fontSize: 12)),
                              Expanded(
                                child: Slider(
                                  value:
                                  settings.lowStockThreshold.toDouble(),
                                  min: 1,
                                  max: 20,
                                  divisions: 19,
                                  label:
                                  '${settings.lowStockThreshold} units',
                                  onChanged: (val) =>
                                      controller.updateLowStockThreshold(
                                          val.round()),
                                ),
                              ),
                              Text(l10n.units20,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Auto-decrement
                        SwitchListTile(
                          secondary: const Icon(Icons.auto_mode_rounded),
                          title: Text(l10n.autoDecrementTitle),
                          subtitle: Text(l10n.autoDecrementSubtitle),
                          value: settings.autoDecrementOnDoseTaken,
                          onChanged: controller.toggleAutoDecrement,
                        ),
                        const Divider(height: 1),

                        // Daily Alerts
                        SwitchListTile(
                          secondary: const Icon(
                              Icons.notifications_active_outlined),
                          title: Text(l10n.dailyAlertsTitle),
                          subtitle: Text(l10n.dailyAlertsSubtitle),
                          value: settings.dailyStockAlertsEnabled,
                          onChanged: controller.toggleDailyStockAlerts,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Demo / Developer ─────────────────────────────────────────────
            _SectionHeader('Developer Tools'),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.science_outlined, color: AppColors.blue),
                title: const Text('Seed Demo Data'),
                subtitle: const Text(
                  'Populate account with sample medications, reminders, dose history, and emergency card for demo.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: user == null
                    ? null
                    : () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      icon: const Icon(Icons.science_outlined, size: 40, color: AppColors.blue),
                      title: const Text('Seed Demo Data'),
                      content: const Text(
                        'This will add sample medications, reminders, dose logs, and an emergency card to your account.\n\nExisting data will NOT be deleted.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Seed Data'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    try {
                      final seeder = DemoDataSeeder();
                      await seeder.seedUserDemoData(user.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Demo data seeded successfully!'),
                            backgroundColor: AppColors.blue,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error seeding data: $e')),
                        );
                      }
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── Account ─────────────────────────────────────────────────────
            _SectionHeader(l10n.settingsAccount),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: Text(l10n.logout),
                    onTap: isLoading
                        ? null
                        : () => _handleSignOut(context, ref, l10n),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded,
                        color: Colors.red),
                    title: Text(
                      l10n.deleteAccount,
                      style: const TextStyle(color: Colors.red),
                    ),
                    subtitle: Text(l10n.deleteFirestoreData),
                    onTap: isLoading
                        ? null
                        : () => _handleDeleteAccount(context, ref, l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}