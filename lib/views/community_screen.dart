// lib/views/community_screen.dart

import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- ESTILO MODIFICADO ---
        title: const Text('Comunidad 🤝'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ICONO MODIFICADO ---
              Icon(Icons.people, size: 80, color: Colors.amber.withOpacity(0.8)),
              const SizedBox(height: 20),
              Text(
                'Próximamente',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // --- TEXTO MODIFICADO ---
              Text(
                'Aquí podrás ver quién más ha completado el reto del día. ¡Sigue participando!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}