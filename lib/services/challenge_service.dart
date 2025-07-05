// lib/services/challenge_service.dart

import 'dart:convert';
import '../models/challenge.dart';

// Simula una llamada a una API
class ChallengeService {
  Future<Challenge> getDailyChallenge() async {
    // Simulamos un retraso de red
    await Future.delayed(const Duration(seconds: 1));

    // En una app real, esto vendría de una petición HTTP (ej: http.get(...))
    // Usamos datos falsos para el ejemplo.
    final today = DateTime.now();
    final mockResponse = {
      "id": "challenge_${today.year}_${today.month}_${today.day}",
      "title": "Reto de Lectura 📖",
      "description": "Lee 20 páginas de cualquier libro. ¡Alimenta tu mente y expande tus horizontes!",
      "type": "reading",
      "date": today.toIso8601String(),
    };

    return Challenge.fromJson(mockResponse);
  }
}