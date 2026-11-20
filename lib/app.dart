import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_meds/core/router/router.dart';
import 'package:my_meds/core/theme/theme.dart';
import 'package:my_meds/features/settings/presentation/providers/locale_providers.dart';
import 'package:my_meds/features/settings/presentation/providers/theme_providers.dart';
import 'package:my_meds/l10n/app_localizations.dart';

/// Root application widget.
///
/// Reads the user-selected [Locale] from [localeProvider] and the theme mode
/// from [themeModeProvider], and passes them to [MaterialApp.router].
/// RTL layout for Arabic is handled automatically once the locale is `ar`.
class MyMedsApp extends ConsumerWidget {
  const MyMedsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider); // null → device default
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      // ── Metadata ──
      title: 'MyMeds',
      debugShowCheckedModeBanner: false,

      // ── Theme (Material 3) ──
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // ── Navigation ──
      routerConfig: router,

      // ── Localization ──
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}