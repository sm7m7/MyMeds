import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/settings/presentation/providers/inventory_settings_providers.dart';

/// Settings and account management screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of MyMeds?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
        title: const Text('Delete Account?'),
        content: const Text(
          'Are you sure you want to permanently delete your account and all associated medication data from Firestore?\n\n'
          'This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await ref.read(authControllerProvider.notifier).deleteAccount();
      if (!success && context.mounted) {
        final errorState = ref.read(authControllerProvider);
        final errorMessage =
            errorState.error?.toString() ?? 'Failed to delete account.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const MedicalDisclaimer(),
            const SizedBox(height: 16),

            // Profile Section Card
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
                            user?.email ?? 'Not logged in',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'UID: ${user?.uid ?? "N/A"}',
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

            // Preferences Section
            Text(
              'Preferences',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: const Text('Language'),
                    subtitle: Text(
                      user?.preferredLanguage == 'fr'
                          ? 'Français'
                          : user?.preferredLanguage == 'ar'
                              ? 'العربية'
                              : 'English',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stock & Expiration Management Section
            Text(
              'Stock & Expiration Thresholds',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final inventorySettings = ref.watch(inventorySettingsProvider);
                final controller = ref.read(inventorySettingsProvider.notifier);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        // Expiring Soon Threshold
                        ListTile(
                          leading: const Icon(Icons.hourglass_bottom_rounded),
                          title: const Text('Expiring Soon Threshold'),
                          subtitle: Text(
                            'Flag medications expiring within ${inventorySettings.expiringSoonDaysThreshold} days',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Text('7d', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Slider(
                                  value: inventorySettings.expiringSoonDaysThreshold.toDouble(),
                                  min: 7,
                                  max: 90,
                                  divisions: 83,
                                  label: '${inventorySettings.expiringSoonDaysThreshold} days',
                                  onChanged: (val) {
                                    controller.updateExpiringSoonDays(val.round());
                                  },
                                ),
                              ),
                              const Text('90d', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Low Stock Threshold
                        ListTile(
                          leading: const Icon(Icons.production_quantity_limits_rounded),
                          title: const Text('Low Stock Threshold'),
                          subtitle: Text(
                            'Flag when quantity is ${inventorySettings.lowStockThreshold} units or fewer',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Text('1 unit', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Slider(
                                  value: inventorySettings.lowStockThreshold.toDouble(),
                                  min: 1,
                                  max: 20,
                                  divisions: 19,
                                  label: '${inventorySettings.lowStockThreshold} units',
                                  onChanged: (val) {
                                    controller.updateLowStockThreshold(val.round());
                                  },
                                ),
                              ),
                              const Text('20 units', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Auto Decrement on Dose Taken
                        SwitchListTile(
                          secondary: const Icon(Icons.auto_mode_rounded),
                          title: const Text('Auto-decrement stock on dose taken'),
                          subtitle: const Text(
                            'Deduct 1 unit from cabinet inventory automatically when marking a dose Taken',
                          ),
                          value: inventorySettings.autoDecrementOnDoseTaken,
                          onChanged: (val) {
                            controller.toggleAutoDecrement(val);
                          },
                        ),
                        const Divider(height: 1),

                        // Daily Stock Alert Notifications
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications_active_outlined),
                          title: const Text('Daily stock & expiry alerts'),
                          subtitle: const Text(
                            'Receive daily notifications summarizing items needing attention',
                          ),
                          value: inventorySettings.dailyStockAlertsEnabled,
                          onChanged: (val) {
                            controller.toggleDailyStockAlerts(val);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Account Actions
            Text(
              'Account',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: const Text('Log Out'),
                    onTap: isLoading ? null : () => _handleSignOut(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('Permanently remove user & Firestore data'),
                    onTap: isLoading
                        ? null
                        : () => _handleDeleteAccount(context, ref),
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
