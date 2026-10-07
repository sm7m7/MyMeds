import 'dart:convert';
import 'package:my_meds/features/cabinet/domain/models/inventory_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting and loading user inventory and expiration threshold settings.
class InventorySettingsRepository {
  InventorySettingsRepository({this.preferences});

  SharedPreferences? preferences;
  static const String _storageKey = 'mymeds_inventory_settings';

  Future<SharedPreferences> _getPrefs() async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!;
  }

  /// Loads stored [InventorySettings] or returns default values if none stored.
  Future<InventorySettings> loadSettings() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> data =
            jsonDecode(raw) as Map<String, dynamic>;
        return InventorySettings.fromJson(data);
      }
    } catch (_) {
      // Fallback to default
    }
    return const InventorySettings();
  }

  /// Saves [InventorySettings] to local storage.
  Future<void> saveSettings(InventorySettings settings) async {
    final prefs = await _getPrefs();
    await prefs.setString(_storageKey, jsonEncode(settings.toJson()));
  }
}
