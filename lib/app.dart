import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_meds/core/router/router.dart';
import 'package:my_meds/core/theme/theme.dart';
import 'package:my_meds/features/settings/presentation/providers/locale_providers.dart';
import 'package:my_meds/l10n/app_localizations.dart';

/// Root application widget.
///
/// Reads the user-selected [Locale] from [localeProvider] and passes it to
/// [MaterialApp.router]. When [locale] is `null`, Flutter automatically uses
/// the device locale and falls back to the first supported locale (English).
///
/// RTL layout for Arabic is handled automatically by Flutter once the locale
/// is set to `ar` — no manual [Directionality] wrappers needed in most widgets.
class MyMedsApp extends ConsumerWidget {
  const MyMedsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider); // null → device default

    return MaterialApp.router(
      // ── Metadata ──
      title: 'MyMeds',
      debugShowCheckedModeBanner: false,

      // ── Theme (Material 3) ──
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── Navigation ──
      routerConfig: router,

      // ── Localization ──
      locale: locale, // drives RTL/LTR + all AppLocalizations lookups
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
