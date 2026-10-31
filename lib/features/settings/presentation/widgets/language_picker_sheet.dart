import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/settings/data/locale_repository.dart';
import 'package:my_meds/features/settings/presentation/providers/locale_providers.dart';
import 'package:my_meds/l10n/app_localizations.dart';

/// Bottom sheet that lets the user pick their preferred language.
///
/// Shows a radio list of all [LocaleRepository.supportedLocales].
/// Selecting a language immediately applies it to the app and persists it.
class LanguagePickerSheet extends ConsumerWidget {
  const LanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final user = ref.watch(currentUserProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              l10n.languagePickerTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Language options
            ...LocaleRepository.supportedLocales.map((locale) {
              final isSelected =
                  currentLocale?.languageCode == locale.languageCode;
              final name = LocaleRepository.localeDisplayNames[locale.languageCode] ??
                  locale.languageCode;

              return ListTile(
                leading: _flagEmoji(locale.languageCode),
                title: Text(name),
                subtitle: _subtitle(locale.languageCode, l10n),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                    : Icon(Icons.radio_button_unchecked_rounded, color: theme.colorScheme.outline),
                selected: isSelected,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () async {
                  await ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(locale.languageCode), uid: user?.uid);
                  if (context.mounted) Navigator.of(context).pop();
                },
              );
            }),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _flagEmoji(String code) {
    const flags = {'en': '🇬🇧', 'fr': '🇫🇷', 'ar': '🇸🇦'};
    return Text(
      flags[code] ?? '🌐',
      style: const TextStyle(fontSize: 28),
    );
  }

  Widget? _subtitle(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return const Text('English');
      case 'fr':
        return const Text('French — Français');
      case 'ar':
        return const Text('Arabic — العربية (RTL)');
      default:
        return null;
    }
  }
}
