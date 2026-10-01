import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Keeps personal attendance reminders on-device. Eight reminders are queued
/// per day: the first at 8 PM and then one every 30 minutes until 11:30 PM.
/// Tapping any one of them cancels the remaining reminders for that date.
class AttendanceReminderService {
  AttendanceReminderService._();

  static final AttendanceReminderService instance =
      AttendanceReminderService._();

  static const _channelId = 'attendance_end_of_day_reminders';
  static const _channelName = 'Attendance reminders';
  static const _channelDescription =
      'Reminders to mark attendance before the day ends.';
  static const _payloadPrefix = 'attendance-reminder|';
  static const _firstReminderHour = 20;
  static const _reminderCount = 8;
  static const _scheduleDaysAhead = 30;
  static const _handledDatePreferenceKey = 'attendance_reminder_handled_date';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _attendanceOpenRequested = false;
  Future<void> Function()? _attendanceTapHandler;

  Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _initialized = true;
      return;
    }

    tz_data.initializeTimeZones();
    try {
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimezone.identifier));
    } catch (_) {
      // The timezone package's default local zone remains a safe fallback.
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_attendance'),
    );
    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    _initialized = true;

    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();
    final launchResponse = launchDetails?.notificationResponse;
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchResponse != null) {
      await _handleNotificationTap(launchResponse.payload);
    }
  }

  void bindAttendanceNavigation(Future<void> Function() handler) {
    _attendanceTapHandler = handler;
    if (_attendanceOpenRequested) {
      unawaited(_openAttendance());
    }
  }

  void clearAttendanceNavigationHandler() {
    _attendanceTapHandler = null;
  }

  Future<AttendanceReminderSetupResult> scheduleForActiveAdmin() async {
    await initialize();
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const AttendanceReminderSetupResult.unsupported();
    }

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final notificationsAllowed =
        await android?.requestNotificationsPermission() ?? false;
    if (!notificationsAllowed) {
      return const AttendanceReminderSetupResult.notificationsDenied();
    }

    final canUseExactAlarms =
        await android?.canScheduleExactNotifications() ?? false;
    final now = tz.TZDateTime.now(tz.local);
    final today = tz.TZDateTime(tz.local, now.year, now.month, now.day);
    final scheduleMode = canUseExactAlarms
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final preferences = await SharedPreferences.getInstance();
    final handledDateKey = preferences.getString(_handledDatePreferenceKey);

    for (var dayOffset = 0; dayOffset < _scheduleDaysAhead; dayOffset++) {
      final day = tz.TZDateTime(
        tz.local,
        today.year,
        today.month,
        today.day + dayOffset,
      );
      if (_dateKey(day) == handledDateKey) continue;
      for (var slot = 0; slot < _reminderCount; slot++) {
        final trigger = tz.TZDateTime(
          tz.local,
          day.year,
          day.month,
          day.day,
          _firstReminderHour + slot ~/ 2,
          slot.isEven ? 0 : 30,
        );
        if (!trigger.isAfter(now)) continue;

        await _notifications.zonedSchedule(
          id: _notificationId(day, slot),
          title: 'Attendance reminder',
          body: slot == 0
              ? 'Today\'s attendance is pending. Tap to start marking.'
              : 'Attendance is still pending. Tap to start marking now.',
          scheduledDate: trigger,
          notificationDetails: _notificationDetails,
          payload: '$_payloadPrefix${_dateKey(day)}',
          androidScheduleMode: scheduleMode,
        );
      }
    }

    return AttendanceReminderSetupResult.scheduled(
      usesExactAlarms: canUseExactAlarms,
    );
  }

  Future<void> cancelRemindersForDate(DateTime date) async {
    await initialize();
    final day = tz.TZDateTime(tz.local, date.year, date.month, date.day);
    for (var slot = 0; slot < _reminderCount; slot++) {
      await _notifications.cancel(id: _notificationId(day, slot));
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    unawaited(_handleNotificationTap(response.payload));
  }

  Future<void> _handleNotificationTap(String? payload) async {
    final date = _dateFromPayload(payload);
    if (date == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_handledDatePreferenceKey, _dateKey(date));
    await cancelRemindersForDate(date);
    _attendanceOpenRequested = true;
    await _openAttendance();
  }

  Future<void> _openAttendance() async {
    final handler = _attendanceTapHandler;
    if (handler == null) return;
    _attendanceOpenRequested = false;
    await handler();
  }

  int _notificationId(tz.TZDateTime date, int slot) {
    return int.parse(DateFormat('yyyyMMdd').format(date)) * 10 + slot;
  }

  DateTime? _dateFromPayload(String? payload) {
    if (payload == null || !payload.startsWith(_payloadPrefix)) return null;
    return DateTime.tryParse(payload.substring(_payloadPrefix.length));
  }

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
    ),
  );

  static String _dateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);
}

class AttendanceReminderSetupResult {
  const AttendanceReminderSetupResult._({
    required this.notificationsAllowed,
    required this.usesExactAlarms,
    required this.isSupported,
  });

  const AttendanceReminderSetupResult.scheduled({required bool usesExactAlarms})
    : this._(
        notificationsAllowed: true,
        usesExactAlarms: usesExactAlarms,
        isSupported: true,
      );

  const AttendanceReminderSetupResult.notificationsDenied()
    : this._(
        notificationsAllowed: false,
        usesExactAlarms: false,
        isSupported: true,
      );

  const AttendanceReminderSetupResult.unsupported()
    : this._(
        notificationsAllowed: false,
        usesExactAlarms: false,
        isSupported: false,
      );

  final bool notificationsAllowed;
  final bool usesExactAlarms;
  final bool isSupported;
}
