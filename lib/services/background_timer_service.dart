// lib/services/background_timer_service.dart

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String notificationChannelId = 'my_foreground';
const int notificationId = 888;

class BackgroundTimerService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'RETOS DIARIOS APP',
      description: 'Este canal se usa para notificaciones importantes.',
      importance: Importance.low,
    );

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Servicio de Retos Activo',
        initialNotificationContent: 'Preparando...',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('startTimer').listen((event) {
    final int durationInSeconds = event!['durationInSeconds'];
    int remainingSeconds = durationInSeconds;

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      remainingSeconds--;

      if (remainingSeconds >= 0) {
        // Enviar progreso a la UI
        service.invoke('update', {
          'remaining_seconds': remainingSeconds,
        });

        // Actualizar la notificación
        final minutes = (remainingSeconds / 60).floor();
        final seconds = remainingSeconds % 60;
        final timeString =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'Reto en progreso...',
          'Tiempo restante: $timeString',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'RETOS DIARIOS APP',
              icon: '@mipmap/ic_launcher',
              ongoing: true,
            ),
          ),
        );
      } else {
        // El temporizador terminó
        timer.cancel();
        flutterLocalNotificationsPlugin.show(
          notificationId,
          '¡Reto completado!',
          '¡Buen trabajo! Has terminado tu sesión.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'RETOS DIARIOS APP',
              icon: '@mipmap/ic_launcher',
              ongoing: false,
            ),
          ),
        );
        service.invoke('timer_finished');
        // NOTA: La lógica de intervalo se manejará desde el Controller para más control.
        service.stopSelf();
      }
    });
  });
}