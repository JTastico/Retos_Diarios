// lib/services/challenge_service.dart

import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/challenge.dart';
import '../config.dart'; // Importamos nuestra API Key

class ChallengeService {
  // Modelo de Gemini a utilizar
  final _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);

  Future<Challenge> getDailyChallenge(Set<ChallengeType> preferredTypes) async {
    final today = DateTime.now();
    try {
      // 1. Crear el prompt para Gemini
      final preferredTypesString = preferredTypes.map((e) => e.name).join(', ');
      final prompt = """
      Genera un único reto creativo y motivador para un usuario interesado en las siguientes categorías: $preferredTypesString.
      El reto debe ser realizable en un solo día.
      Proporciona la respuesta exclusivamente como un objeto JSON válido con las siguientes claves:
      - "title": un título corto y pegadizo que incluya un emoji apropiado.
      - "description": una descripción de 1 a 2 frases.
      - "type": una de las siguientes cadenas de texto que corresponda a la categoría del reto: 'fitness', 'reading', 'mindfulness'.
      
      No incluyas texto adicional ni formato markdown fuera del objeto JSON.
      Ejemplo de respuesta:
      {
        "title": "Paseo Consciente 🌳",
        "description": "Realiza una caminata de 15 minutos prestando total atención a tu entorno, los sonidos y tu respiración.",
        "type": "mindfulness"
      }
      """;

      // 2. Realizar la llamada a la API
      final response = await _model.generateContent([Content.text(prompt)]);
      
      // 3. Limpiar y decodificar la respuesta JSON
      final cleanedResponse = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonResponse = jsonDecode(cleanedResponse);

      // 4. Crear el objeto Challenge a partir de la respuesta
      return Challenge(
        id: "challenge_${today.year}_${today.month}_${today.day}",
        title: jsonResponse['title'] ?? 'Reto Misterioso',
        description: jsonResponse['description'] ?? 'Hoy, sorpréndete a ti mismo.',
        type: ChallengeType.values.firstWhere(
          (e) => e.name == jsonResponse['type'],
          orElse: () => preferredTypes.first, // Fallback al primer tipo preferido
        ),
        date: today,
      );

    } catch (e) {
      // Si la API falla, devolver un reto de fallback
      print('Error al llamar a la API de Gemini: $e');
      return _getFallbackChallenge(today, preferredTypes.first);
    }
  }
  
  // Reto de emergencia si la API falla
  Challenge _getFallbackChallenge(DateTime date, ChallengeType type) {
    return Challenge(
      id: "fallback_${date.year}_${date.month}_${date.day}",
      title: "Reto de Respaldo ⚙️",
      description: "La conexión con nuestro generador de retos falló. ¡Intenta meditar por 5 minutos y vuelve a intentarlo más tarde!",
      type: type,
      date: date,
    );
  }
}