import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_meds/core/router/router.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/settings/presentation/providers/locale_providers.dart';
import 'package:my_meds/features/settings/presentation/providers/theme_providers.dart';
import 'package:my_meds/features/settings/presentation/widgets/language_picker_sheet.dart';
import 'package:my_meds/l10n/app_localizations.dart';

/// More / Menu tab screen.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MedicalDisclaimer(),
          const SizedBox(height: 16),

          // Profile card
          if (user != null)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user.email),
                subtitle: Text(l10n.settings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.settings),
              ),
            ),
          const SizedBox(height: 8),


          // Healthcare & Pharmacy Locator
          ListTile(
            leading: const Icon(Icons.local_hospital_outlined),
            title: const Text('Pharmacies & Healthcare'),
            subtitle: const Text('Find nearby pharmacies and clinics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.locator),
          ),

          // Emergency Medical Card
          ListTile(
            leading: Icon(
              Icons.contact_emergency_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text(
              'Emergency Medical Card',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Offline medical ID, allergies & emergency contacts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.emergencyCard),
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.settings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settings),
          ),

          // Dark mode switch
          SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            title: const Text('Dark mode'),
            value: isDark,
            onChanged: (value) => ref
                .read(themeModeProvider.notifier)
                .setMode(value ? ThemeMode.dark : ThemeMode.light),
          ),

          // Language
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language),
            subtitle: Text(
              locale?.languageCode == 'fr'
                  ? 'Français'
                  : locale?.languageCode == 'ar'
                  ? 'العربية'
                  : 'English',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => LanguagePickerSheet.show(context),
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            subtitle: Text(l10n.appVersion('1.0.0')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: '1.0.0',
                applicationLegalese: l10n.medicalDisclaimer,
              );
            },
          ),
          const Divider(height: 32),

          // Footer disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.medicalDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}