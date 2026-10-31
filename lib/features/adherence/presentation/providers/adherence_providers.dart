import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/adherence/domain/models/adherence_models.dart';
import 'package:my_meds/features/adherence/domain/services/adherence_service.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/reminders/domain/models/dose_log.dart';
import 'package:my_meds/features/reminders/presentation/providers/reminders_providers.dart';

final adherenceServiceProvider = Provider<AdherenceService>((ref) {
  return const AdherenceService();
});

/// Active period selected on dashboard (Week vs Month).
final selectedAdherencePeriodProvider =
    StateProvider<AdherencePeriod>((ref) => AdherencePeriod.week);

/// Fetches dose logs for the active adherence period.
final adherenceLogsRangeProvider =
    FutureProvider.autoDispose<List<DoseLog>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final period = ref.watch(selectedAdherencePeriodProvider);
  final now = DateTime.now();
  final start = now.subtract(Duration(days: period.days));
  final end = now;

  final repository = ref.watch(doseLogRepositoryProvider);
  return repository.getDoseLogsForRange(user.uid, start, end);
});

/// Computes overall adherence summary for the active period.
final adherenceSummaryProvider =
    Provider.autoDispose<AsyncValue<AdherenceSummary>>((ref) {
  final logsAsync = ref.watch(adherenceLogsRangeProvider);
  final period = ref.watch(selectedAdherencePeriodProvider);
  final service = ref.watch(adherenceServiceProvider);

  return logsAsync.whenData((logs) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: period.days));
    return service.computeSummary(
      logs: logs,
      periodStart: start,
      periodEnd: now,
    );
  });
});

/// Computes daily breakdown for weekly/monthly bar charts.
final dailyAdherenceListProvider =
    Provider.autoDispose<AsyncValue<List<DailyAdherence>>>((ref) {
  final logsAsync = ref.watch(adherenceLogsRangeProvider);
  final period = ref.watch(selectedAdherencePeriodProvider);
  final service = ref.watch(adherenceServiceProvider);

  return logsAsync.whenData((logs) {
    return service.computeDailyBreakdown(
      logs: logs,
      endDate: DateTime.now(),
      daysCount: period == AdherencePeriod.week ? 7 : 14,
    );
  });
});

/// Computes per-medication adherence ranking for the period.
final perMedicationAdherenceProvider =
    Provider.autoDispose<AsyncValue<List<MedicationAdherence>>>((ref) {
  final logsAsync = ref.watch(adherenceLogsRangeProvider);
  final service = ref.watch(adherenceServiceProvider);

  return logsAsync.whenData((logs) {
    return service.computePerMedicationAdherence(logs: logs);
  });
});

/// History filter state providers
final doseHistoryStatusFilterProvider =
    StateProvider<DoseLogStatus?>((ref) => null);

final doseHistoryMedicationFilterProvider =
    StateProvider<String?>((ref) => null);

/// Filtered dose logs for chronological history view.
final filteredDoseHistoryProvider =
    Provider.autoDispose<AsyncValue<List<DoseLog>>>((ref) {
  final logsAsync = ref.watch(adherenceLogsRangeProvider);
  final statusFilter = ref.watch(doseHistoryStatusFilterProvider);
  final medFilter = ref.watch(doseHistoryMedicationFilterProvider);

  return logsAsync.whenData((logs) {
    var result = List<DoseLog>.from(logs);

    if (statusFilter != null) {
      result = result.where((l) => l.status == statusFilter).toList();
    }

    if (medFilter != null && medFilter.isNotEmpty) {
      result = result.where((l) => l.medicationId == medFilter).toList();
    }

    // Sort in reverse chronological order (newest first)
    result.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    return result;
  });
});
