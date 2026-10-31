import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/settings/data/locale_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────────────────────────────────────

final localeRepositoryProvider = Provider<LocaleRepository>((ref) {
  return LocaleRepository();
});

// ─────────────────────────────────────────────────────────────────────────────
// Locale state notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Manages the app-wide [Locale].
///
/// On first load, reads from SharedPreferences.
/// If nothing is stored, falls back to the [AppUser.preferredLanguage] from
/// Firestore, which was set at registration time.
/// If still nothing, a `null` locale tells [MaterialApp] to use the device locale.
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._repository) : super(null) {
    _load();
  }

  final LocaleRepository _repository;

  Future<void> _load() async {
    final persisted = await _repository.loadLocale();
    if (persisted != null) {
      state = persisted;
    }
    // If null, leave state as null → MaterialApp uses device locale.
  }

  /// Changes the locale, persists it locally, and syncs to Firestore if signed in.
  Future<void> setLocale(Locale locale, {String? uid}) async {
    state = locale;
    await _repository.saveLocale(locale);

    // Sync preferredLanguage to Firestore user doc (best-effort, no throw).
    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'preferredLanguage': locale.languageCode});
      } catch (_) {}
    }
  }

  /// Resets to null (device locale) and removes persisted preference.
  Future<void> clearLocale() async {
    state = null;
    await _repository.clearLocale();
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.watch(localeRepositoryProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Helper: initialize from Firestore user doc on first sign-in
// ─────────────────────────────────────────────────────────────────────────────

/// Call this once (e.g. after Google sign-in) to seed the locale from the
/// Firestore user doc when no local preference is stored yet.
Future<void> seedLocaleFromUser(Ref ref) async {
  final stored = await ref.read(localeRepositoryProvider).loadLocale();
  if (stored != null) return; // Already have a local preference.

  final user = ref.read(currentUserProvider);
  if (user == null) return;

  final lang = user.preferredLanguage;
  final supported = LocaleRepository.supportedLocales;
  final match = supported.firstWhere(
    (l) => l.languageCode == lang,
    orElse: () => const Locale('en'),
  );
  await ref.read(localeProvider.notifier).setLocale(match);
}
