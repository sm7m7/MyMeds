import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/cabinet/domain/models/inventory_settings.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/services/stock_expiration_service.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/settings/data/inventory_settings_repository.dart';

final inventorySettingsRepositoryProvider =
    Provider<InventorySettingsRepository>((ref) {
  return InventorySettingsRepository();
});

final stockExpirationServiceProvider =
    Provider<StockExpirationService>((ref) {
  return const StockExpirationService();
});

/// StateNotifier managing user inventory threshold preferences.
class InventorySettingsController extends StateNotifier<InventorySettings> {
  InventorySettingsController(this._repository)
      : super(const InventorySettings()) {
    _load();
  }

  final InventorySettingsRepository _repository;

  Future<void> _load() async {
    final loaded = await _repository.loadSettings();
    state = loaded;
  }

  Future<void> updateExpiringSoonDays(int days) async {
    final updated = state.copyWith(expiringSoonDaysThreshold: days);
    state = updated;
    await _repository.saveSettings(updated);
  }

  Future<void> updateLowStockThreshold(int threshold) async {
    final updated = state.copyWith(lowStockThreshold: threshold);
    state = updated;
    await _repository.saveSettings(updated);
  }

  Future<void> toggleAutoDecrement(bool enabled) async {
    final updated = state.copyWith(autoDecrementOnDoseTaken: enabled);
    state = updated;
    await _repository.saveSettings(updated);
  }

  Future<void> toggleDailyStockAlerts(bool enabled) async {
    final updated = state.copyWith(dailyStockAlertsEnabled: enabled);
    state = updated;
    await _repository.saveSettings(updated);
  }

  Future<void> updateDailyAlertTime(int hour, int minute) async {
    final updated = state.copyWith(
      dailyAlertHour: hour,
      dailyAlertMinute: minute,
    );
    state = updated;
    await _repository.saveSettings(updated);
  }
}

final inventorySettingsProvider =
    StateNotifierProvider<InventorySettingsController, InventorySettings>((ref) {
  return InventorySettingsController(
    ref.watch(inventorySettingsRepositoryProvider),
  );
});

/// Filtered list of medications needing user attention (expired, expiring soon, low stock).
final attentionNeededMedicationsProvider =
    Provider.autoDispose<List<Medication>>((ref) {
  final medicationsAsync = ref.watch(cabinetMedicationsStreamProvider);
  final settings = ref.watch(inventorySettingsProvider);
  final service = ref.watch(stockExpirationServiceProvider);

  final medications = medicationsAsync.valueOrNull ?? [];
  return service.filterAttentionNeeded(medications, settings: settings);
});
