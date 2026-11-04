import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/agenda_event.dart';

/// Recordatorios locales de Android. En web no hace nada.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _taps = StreamController<String>.broadcast();

  bool _ready = false;
  String? _initialEventId;

  /// Evento que abrió la app desde una notificación (arranque en frío).
  String? takeInitialEventId() {
    final id = _initialEventId;
    _initialEventId = null;
    return id;
  }

  Stream<String> get taps => _taps.stream;

  Future<void> init() async {
    if (kIsWeb || _ready) return;
    try {
      tz_data.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) _taps.add(payload);
        },
      );
      _ready = true;

      final launch = await _plugin.getNotificationAppLaunchDetails();
      final payload = launch?.notificationResponse?.payload;
      if (launch?.didNotificationLaunchApp == true && payload != null) {
        _initialEventId = payload;
      }
    } catch (_) {
      // Si el plugin falla, la app sigue funcionando sin recordatorios.
    }
  }

  Future<bool> requestPermission() async {
    if (kIsWeb || !_ready) return false;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestExactAlarmPermission() async {
    if (kIsWeb || !_ready) return false;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (await android?.canScheduleExactNotifications() ?? false) return true;
      return await android?.requestExactAlarmsPermission() ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncEvent(AgendaEvent event, {required bool enabled}) async {
    if (kIsWeb || !_ready) return;
    await cancel(event.id);
    if (!enabled || event.isCompleted || event.reminderMinutes < 0) return;

    final when = event.dateTime.subtract(
      Duration(minutes: event.reminderMinutes),
    );
    if (!when.isAfter(DateTime.now())) return;

    final time =
        '${event.dateTime.hour.toString().padLeft(2, '0')}:'
        '${event.dateTime.minute.toString().padLeft(2, '0')}';
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    Future<void> schedule(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id: _notificationId(event.id),
      title: event.title,
      body: '${event.subject} • $time hs',
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nexora_events',
          'Recordatorios de eventos',
          channelDescription: 'Avisos de exámenes, entregas y presentaciones',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: mode,
      payload: event.id,
    );

    try {
      final canScheduleExact =
          await android?.canScheduleExactNotifications() ?? false;
      await schedule(
        canScheduleExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // Si Android revoca el acceso exacto, conserva el aviso con precisión reducida.
      try {
        await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
      } catch (_) {
        // El evento se conserva aunque Android no acepte programar el aviso.
      }
    }
  }

  Future<void> cancel(String eventId) async {
    if (kIsWeb || !_ready) return;
    try {
      await _plugin.cancel(id: _notificationId(eventId));
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (kIsWeb || !_ready) return;
    try {
      await _plugin.cancelAllPendingNotifications();
    } catch (_) {}
  }

  Future<void> rescheduleAll(
    Iterable<AgendaEvent> events, {
    required bool enabled,
  }) async {
    if (kIsWeb || !_ready) return;
    await cancelAll();
    if (!enabled) return;
    for (final event in events) {
      await syncEvent(event, enabled: true);
    }
  }

  // shortcut: hash de 31 bits; dos IDs distintos podrían compartir recordatorio.
  // Si aparece una colisión real, guardar un mapa id→entero en preferencias.
  int _notificationId(String eventId) {
    var hash = 0;
    for (final code in eventId.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }
}
