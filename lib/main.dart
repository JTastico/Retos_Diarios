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

// --- Painter para el fondo degradado global ---
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const HSLColor.fromAHSL(1.0, 260, 0.6, 0.6).toColor(),
        const HSLColor.fromAHSL(1.0, 220, 0.7, 0.6).toColor(),
        const HSLColor.fromAHSL(1.0, 180, 0.7, 0.5).toColor(),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


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
  
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: SplashApp(),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );

  await _initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ChallengeController(),
      child: const MainApp(),
    ),
  );
}

Future<void> _initializeApp() async {
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
}

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onInitializationComplete: () {},
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retos Diarios',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        cardTheme: CardThemeData(
          color: Colors.black.withAlpha(77),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: Colors.white.withAlpha(51)),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.bold)
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
        final session = snapshot.data?.session;

        // --- CAMBIO: AÑADIDO ANIMATED SWITCHER PARA LA TRANSICIÓN DE LOGIN ---
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: session != null
              ? const RetosDiariosApp(key: ValueKey('app')) // Key única para la app
              : const AuthScreen(key: ValueKey('auth')),     // Key única para el login
        );
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
      body: CustomPaint(
        painter: BackgroundPainter(),
        size: MediaQuery.of(context).size,
        // --- CAMBIO: AÑADIDO ANIMATED SWITCHER PARA TRANSICIÓN ENTRE PESTAÑAS ---
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Center(
            // La key es crucial para que AnimatedSwitcher detecte el cambio de widget
            key: ValueKey<int>(_selectedIndex),
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black.withOpacity(0.5),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Reto'),
          BottomNavigationBarItem(icon: Icon(Icons.military_tech), label: 'Insignias'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Comunidad'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        onTap: _onItemTapped,
      ),
    );
  }
}