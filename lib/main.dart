// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'controllers/challenge_controller.dart';
import 'services/background_timer_service.dart'; // Importar servicio
import 'views/home_screen.dart';
import 'views/badges_screen.dart';
import 'views/community_screen.dart';
import 'views/profile_screen.dart';

// Workaround para errores de certificado en desarrollo (opcional)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  // Asegurarse de que los bindings de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // Pedir permiso de notificaciones
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  // Inicializar el servicio en segundo plano
  await BackgroundTimerService().initializeService();
  
  HttpOverrides.global = MyHttpOverrides();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChallengeController(),
      child: const RetosDiariosApp(),
    ),
  );
}

// ... el resto del archivo `main.dart` no cambia ...

class RetosDiariosApp extends StatefulWidget {
  const RetosDiariosApp({super.key});

  @override
  State<RetosDiariosApp> createState() => _RetosDiariosAppState();
}

class _RetosDiariosAppState extends State<RetosDiariosApp> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BadgesScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retos Diarios',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Reto',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech),
              label: 'Insignias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Comunidad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.indigo,
          onTap: _onItemTapped,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}