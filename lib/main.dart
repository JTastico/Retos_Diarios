// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'controllers/challenge_controller.dart';
import 'services/background_timer_service.dart';
import 'views/auth_screen.dart';
import 'views/home_screen.dart';
import 'views/badges_screen.dart';
import 'views/community_screen.dart';
import 'views/profile_screen.dart';
import 'views/splash_screen.dart';

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
  
  // Mostrar splash screen inmediatamente
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SplashApp(),
      ),
    ),
  );

  // Inicializar todo en segundo plano
  await _initializeApp();

  // Lanzar la app principal cuando todo esté listo
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChallengeController(),
      child: const MainApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Manejar permisos
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  // Inicializar servicios en segundo plano
  await BackgroundTimerService().initializeService();
}

// Splash Screen temporal (se muestra mientras se inicializa)
class SplashApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onInitializationComplete: () {}, // No se usa aquí
    );
  }
}

// App principal
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
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Gestor de autenticación
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Si está autenticado, mostrar la app principal
        if (snapshot.hasData && snapshot.data!.session != null) {
          return const RetosDiariosApp();
        }
        // Si no, mostrar login
        return const AuthScreen();
      },
    );
  }
}

// App principal con navegación
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