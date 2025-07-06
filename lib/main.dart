import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Canal de notificación para el servicio en primer plano
const String notificationChannelId = 'my_foreground';
const int notificationId = 888;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

//--- FUNCIÓN DE INICIALIZACIÓN DEL SERVICIO ---
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Configura el canal de notificación para Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'RETO ACTIVO', // Título del canal
    description: 'Este canal se usa para mostrar el estado del reto activo.',
    importance: Importance.low, // Importancia baja para que no sea intrusiva
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false, // Iniciaremos el servicio manualmente con el botón
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'CodeLink Reto',
      initialNotificationContent: 'Esperando para iniciar...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}

//--- PUNTO DE ENTRADA PARA EL SERVICIO EN SEGUNDO PLANO ---
// ESTA FUNCIÓN CORRE EN SU PROPIO ISOLATE (SEGUNDO PLANO)
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // DartPluginRegistrant.ensureInitialized() se remueve de aquí porque causa el error.
  
  DateTime? startTime;
  
  // Escucha eventos que vienen desde la UI
  service.on('startChallenge').listen((event) {
    startTime = DateTime.now();
    
    // Inicia un temporizador que se ejecuta cada segundo
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (startTime == null) {
        timer.cancel();
        return;
      }

      final duration = DateTime.now().difference(startTime!);
      
      // Formatea la duración en hh:mm:ss
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      final
 
formattedTime = "$hours:$minutes:$seconds";
      
      // Envía la actualización del tiempo a la UI
      service.invoke(
        'update',
        {
          "time": formattedTime,
        },
      );
    });
  });

  service.on('stopChallenge').listen((event) {
    startTime = null; // Detiene el temporizador
    service.stopSelf();
  });
}

// El resto de tu app
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... tu home page
    );
  }
}