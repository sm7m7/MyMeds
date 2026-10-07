import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';
import 'package:my_meds/features/reminders/domain/services/dose_schedule_service.dart';
import 'package:my_meds/features/reminders/domain/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Action IDs for notification quick actions.
class NotificationActions {
  NotificationActions._();
  static const String taken = 'TAKEN';
  static const String skip = 'SKIP';
}

/// Service implementing [NotificationService] using [FlutterLocalNotificationsPlugin].
class LocalNotificationService implements NotificationService {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    DoseScheduleService? scheduleService,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _scheduleService = scheduleService ?? const DoseScheduleService();

  final FlutterLocalNotificationsPlugin _plugin;
  final DoseScheduleService _scheduleService;
  bool _initialized = false;

  static const String channelId = 'medication_reminders_channel';
  static const String channelName = 'Medication Reminders';
  static const String channelDesc = 'Timely alerts for your scheduled medication doses.';

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Timezone initialization error: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create high importance Android notification channel
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        const androidChannel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(androidChannel);
      }
    }

    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS || Platform.isMacOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  @override
  Future<void> scheduleReminderNotifications(MedicationReminder reminder) async {
    await initialize();

    // Cancel existing notifications for this reminder first
    await cancelReminderNotifications(reminder.id);

    if (!reminder.isActive) return;

    final now = DateTime.now();
    // Schedule up to 7 days in advance
    final daysToSchedule = reminder.durationDays != null
        ? reminder.durationDays!.clamp(1, 7)
        : 7;

    for (int dayOffset = 0; dayOffset < daysToSchedule; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final doseTimes = _scheduleService.generateDoseTimesForDate(reminder, targetDate);

      for (int i = 0; i < doseTimes.length; i++) {
        final doseTime = doseTimes[i];
        if (doseTime.isBefore(now)) continue;

        final notificationId = _generateNotificationId(reminder.id, dayOffset, i);
        final tzDateTime = tz.TZDateTime.from(doseTime, tz.local);

        final androidDetails = AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Medication reminder',
          actions: const <AndroidNotificationAction>[
            AndroidNotificationAction(
              NotificationActions.taken,
              'Taken',
              showsUserInterface: true,
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              NotificationActions.skip,
              'Skip',
              showsUserInterface: false,
              cancelNotification: true,
            ),
          ],
        );

        const darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'medication_category',
        );

        final notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
        );

        try {
          await _plugin.zonedSchedule(
            notificationId,
            'Time for ${reminder.medicationName}',
            'Dose: ${reminder.dosage}. Informational only.',
            tzDateTime,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: '${reminder.id}|${reminder.medicationId}|${doseTime.toIso8601String()}',
          );
        } catch (e) {
          debugPrint('Failed to schedule notification $notificationId: $e');
        }
      }
    }
  }

  @override
  Future<void> cancelReminderNotifications(String reminderId) async {
    await initialize();
    // Base notification ID hash
    final baseHash = reminderId.hashCode.abs() % 10000;
    // Cancel maximum potential slot allocations for this reminder
    for (int dayOffset = 0; dayOffset < 8; dayOffset++) {
      for (int slot = 0; slot < 10; slot++) {
        final id = (baseHash * 100) + (dayOffset * 10) + slot;
        await _plugin.cancel(id);
      }
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await initialize();
    await _plugin.cancelAll();
  }

  int _generateNotificationId(String reminderId, int dayOffset, int slotIndex) {
    final baseHash = reminderId.hashCode.abs() % 10000;
    return (baseHash * 100) + (dayOffset * 10) + slotIndex;
  }

  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Foreground notification response: action=${response.actionId}, payload=${response.payload}');
  }
}

/// Top-level callback required by flutter_local_notifications for background action clicks.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('Background notification tapped: ${notificationResponse.actionId}');
}
