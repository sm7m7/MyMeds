import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/reminders/data/firestore_dose_log_repository.dart';
import 'package:my_meds/features/reminders/data/firestore_reminders_repository.dart';
import 'package:my_meds/features/reminders/data/services/fcm_service.dart';
import 'package:my_meds/features/reminders/data/services/local_notification_service.dart';
import 'package:my_meds/features/reminders/domain/models/dose_log.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';
import 'package:my_meds/features/reminders/domain/repositories/dose_log_repository.dart';
import 'package:my_meds/features/reminders/domain/repositories/reminders_repository.dart';
import 'package:my_meds/features/reminders/domain/services/dose_schedule_service.dart';
import 'package:my_meds/features/reminders/domain/services/notification_service.dart';
import 'package:my_meds/features/settings/presentation/providers/inventory_settings_providers.dart';

/// Repository Providers
final remindersRepositoryProvider = Provider<RemindersRepository>((ref) {
  return FirestoreRemindersRepository();
});

final doseLogRepositoryProvider = Provider<DoseLogRepository>((ref) {
  return FirestoreDoseLogRepository();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});

final doseScheduleServiceProvider = Provider<DoseScheduleService>((ref) {
  return const DoseScheduleService();
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

/// Stream of all reminders for the authenticated user.
final userRemindersStreamProvider =
    StreamProvider.autoDispose<List<MedicationReminder>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(const []);
  }

  final repository = ref.watch(remindersRepositoryProvider);
  return repository.watchReminders(user.uid);
});

/// Stream of today's recorded dose logs for the authenticated user.
final todayDoseLogsStreamProvider =
    StreamProvider.autoDispose<List<DoseLog>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(const []);
  }

  final repository = ref.watch(doseLogRepositoryProvider);
  return repository.watchDoseLogsForDay(user.uid, DateTime.now());
});

/// Provider computing today's dose occurrences (upcoming, taken, skipped, missed).
final todayOccurrencesProvider =
    Provider.autoDispose<AsyncValue<List<DoseOccurrence>>>((ref) {
  final remindersAsync = ref.watch(userRemindersStreamProvider);
  final logsAsync = ref.watch(todayDoseLogsStreamProvider);
  final scheduleService = ref.watch(doseScheduleServiceProvider);

  if (remindersAsync.isLoading || logsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (remindersAsync.hasError) {
    return AsyncValue.error(remindersAsync.error!, remindersAsync.stackTrace!);
  }
  if (logsAsync.hasError) {
    return AsyncValue.error(logsAsync.error!, logsAsync.stackTrace!);
  }

  final reminders = remindersAsync.value ?? [];
  final logs = logsAsync.value ?? [];
  final now = DateTime.now();

  final occurrences = scheduleService.generateTodayOccurrences(
    reminders: reminders,
    todayLogs: logs,
    now: now,
  );

  return AsyncValue.data(occurrences);
});

/// State for Reminder operations.
sealed class ReminderActionState {
  const ReminderActionState();
}

class ReminderActionIdle extends ReminderActionState {
  const ReminderActionIdle();
}

class ReminderActionLoading extends ReminderActionState {
  const ReminderActionLoading();
}

class ReminderActionSuccess extends ReminderActionState {
  const ReminderActionSuccess([this.message]);
  final String? message;
}

class ReminderActionError extends ReminderActionState {
  const ReminderActionError(this.message);
  final String message;
}

/// Controller for creating, updating, toggling, and deleting reminders.
class ReminderCrudController extends StateNotifier<ReminderActionState> {
  ReminderCrudController({
    required this.remindersRepository,
    required this.notificationService,
    required this.ref,
  }) : super(const ReminderActionIdle());

  final RemindersRepository remindersRepository;
  final NotificationService notificationService;
  final Ref ref;

  String? get _currentUserId =>
      ref.read(currentUserProvider)?.uid;

  Future<bool> saveReminder(MedicationReminder reminder) async {
    final uid = _currentUserId;
    if (uid == null) {
      state = const ReminderActionError('You must be signed in to save reminders.');
      return false;
    }

    state = const ReminderActionLoading();
    try {
      if (reminder.id.isEmpty) {
        await remindersRepository.addReminder(uid, reminder);
      } else {
        await remindersRepository.updateReminder(uid, reminder);
      }

      // Schedule local notifications if reminder is active
      if (reminder.isActive) {
        await notificationService.scheduleReminderNotifications(reminder);
      } else {
        await notificationService.cancelReminderNotifications(reminder.id);
      }

      state = const ReminderActionSuccess('Reminder saved successfully.');
      return true;
    } catch (e) {
      state = ReminderActionError('Failed to save reminder: $e');
      return false;
    }
  }

  Future<void> toggleActive(MedicationReminder reminder, bool isActive) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      await remindersRepository.toggleReminderActive(uid, reminder.id, isActive);
      if (isActive) {
        await notificationService.scheduleReminderNotifications(
          reminder.copyWith(isActive: true),
        );
      } else {
        await notificationService.cancelReminderNotifications(reminder.id);
      }
    } catch (e) {
      state = ReminderActionError('Failed to update reminder status: $e');
    }
  }

  Future<bool> deleteReminder(String reminderId) async {
    final uid = _currentUserId;
    if (uid == null) return false;

    state = const ReminderActionLoading();
    try {
      await remindersRepository.deleteReminder(uid, reminderId);
      await notificationService.cancelReminderNotifications(reminderId);
      state = const ReminderActionSuccess('Reminder deleted.');
      return true;
    } catch (e) {
      state = ReminderActionError('Failed to delete reminder: $e');
      return false;
    }
  }
}

final reminderCrudControllerProvider =
    StateNotifierProvider.autoDispose<ReminderCrudController, ReminderActionState>((ref) {
  return ReminderCrudController(
    remindersRepository: ref.watch(remindersRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
    ref: ref,
  );
});

/// Controller for marking doses as Taken or Skipped with automatic inventory deduction.
class DoseActionController extends StateNotifier<AsyncValue<void>> {
  DoseActionController({
    required this.doseLogRepository,
    required this.ref,
  }) : super(const AsyncValue.data(null));

  final DoseLogRepository doseLogRepository;
  final Ref ref;

  String? get _currentUserId =>
      ref.read(currentUserProvider)?.uid;

  Future<void> markDose({
    required DoseOccurrence occurrence,
    required DoseLogStatus status,
    String? notes,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    state = const AsyncValue.loading();
    try {
      final log = DoseLog(
        id: occurrence.doseLog?.id ?? '',
        reminderId: occurrence.reminder.id,
        medicationId: occurrence.reminder.medicationId,
        medicationName: occurrence.reminder.medicationName,
        dosage: occurrence.reminder.dosage,
        scheduledTime: occurrence.scheduledTime,
        actualTime: DateTime.now(),
        status: status,
        notes: notes ?? occurrence.doseLog?.notes,
        createdAt: occurrence.doseLog?.createdAt ?? DateTime.now(),
      );

      await doseLogRepository.recordDoseLog(uid, log);

      // Automatic inventory decrement when dose is taken
      if (status == DoseLogStatus.taken && !occurrence.isTaken) {
        final settings = ref.read(inventorySettingsProvider);
        if (settings.autoDecrementOnDoseTaken &&
            occurrence.reminder.medicationId.isNotEmpty) {
          final cabinetRepo = ref.read(cabinetRepositoryProvider);
          final med = await cabinetRepo.getMedicationById(
            uid,
            occurrence.reminder.medicationId,
          );
          if (med != null && med.quantity > 0) {
            final stockService = ref.read(stockExpirationServiceProvider);
            final updatedMed = stockService.decrementQuantity(med);
            await cabinetRepo.updateMedication(uid, updatedMed);
          }
        }
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final doseActionControllerProvider =
    StateNotifierProvider.autoDispose<DoseActionController, AsyncValue<void>>((ref) {
  return DoseActionController(
    doseLogRepository: ref.watch(doseLogRepositoryProvider),
    ref: ref,
  );
});
