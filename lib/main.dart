// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importar Supabase
import 'config.dart'; // Importar config
import 'controllers/challenge_controller.dart';
import 'services/background_timer_service.dart';
import 'views/auth_screen.dart'; // Importar la nueva pantalla de login
import 'views/home_screen.dart';
import 'views/badges_screen.dart';
import 'views/community_screen.dart';
import 'views/profile_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // --- NUEVO: Inicializar Supabase ---
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  await BackgroundTimerService().initializeService();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChallengeController(),
      child: const MainApp(), // Cambiado a un widget principal
    ),
  );
}

// --- NUEVO: Widget principal que envuelve toda la app ---
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retos Diarios',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      // --- NUEVO: AuthGate para decidir qué pantalla mostrar ---
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- NUEVO: Widget que gestiona el estado de la sesión ---
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Si hay una sesión activa, muestra la app principal
        if (snapshot.hasData && snapshot.data!.session != null) {
          return const RetosDiariosApp();
        }
        // Si no, muestra la pantalla de login
        return const AuthScreen();
      },
    );
  }
}

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
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Reto'),
          BottomNavigationBarItem(icon: Icon(Icons.military_tech), label: 'Insignias'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Comunidad'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}