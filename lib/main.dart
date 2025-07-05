// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/challenge_controller.dart';
import 'views/home_screen.dart';
import 'views/badges_screen.dart';
import 'views/community_screen.dart';
import 'views/profile_screen.dart'; // Importamos la nueva pantalla

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChallengeController(),
      child: const RetosDiariosApp(),
    ),
  );
}

class RetosDiariosApp extends StatefulWidget {
  const RetosDiariosApp({super.key});

  @override
  State<RetosDiariosApp> createState() => _RetosDiariosAppState();
}

class _RetosDiariosAppState extends State<RetosDiariosApp> {
  int _selectedIndex = 0;

  // Añadimos la ProfileScreen a la lista de widgets
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BadgesScreen(),
    CommunityScreen(),
    ProfileScreen(), // Nueva pantalla
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
          // Importante: para más de 3 items, el tipo cambia a shifting por defecto
          // Lo forzamos a 'fixed' para mantener un diseño consistente.
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
             BottomNavigationBarItem( // Nuevo item de navegación
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