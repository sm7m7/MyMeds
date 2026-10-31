import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository that persists the user's selected [Locale] locally
/// (SharedPreferences) and optionally syncs it to Firestore.
///
/// Key: `mymeds_locale`  — value: BCP-47 language tag, e.g. `"en"`, `"fr"`, `"ar"`.
class LocaleRepository {
  LocaleRepository({this.preferences});

  SharedPreferences? preferences;

  static const String _key = 'mymeds_locale';

  /// Supported locales, in the order shown in the picker.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  /// Human-readable name for each locale.
  static const Map<String, String> localeDisplayNames = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
  };

  Future<SharedPreferences> _prefs() async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!;
  }

  /// Loads the persisted locale, or `null` if the user hasn't chosen yet
  /// (caller should then fall back to the device locale).
  Future<Locale?> loadLocale() async {
    try {
      final prefs = await _prefs();
      final tag = prefs.getString(_key);
      if (tag != null && tag.isNotEmpty) return Locale(tag);
    } catch (_) {}
    return null;
  }

  /// Saves the selected [locale] locally.
  Future<void> saveLocale(Locale locale) async {
    final prefs = await _prefs();
    await prefs.setString(_key, locale.languageCode);
  }

  /// Clears the stored locale (revert to device default).
  Future<void> clearLocale() async {
    final prefs = await _prefs();
    await prefs.remove(_key);
  }
}
