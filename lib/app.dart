import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_meds/core/router/router.dart';
import 'package:my_meds/core/theme/theme.dart';
import 'package:my_meds/l10n/app_localizations.dart';

/// Root application widget.
class MyMedsApp extends ConsumerWidget {
  const MyMedsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

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
