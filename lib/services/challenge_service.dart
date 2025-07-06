// lib/services/challenge_service.dart

import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/challenge.dart';
import '../config.dart';

class ChallengeService {
  final _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);

  Future<Challenge> getDailyChallenge(Set<String> preferredTypes) async {
    final today = DateTime.now();
    try {
      final preferredTypesString = preferredTypes.join(', ');
      
      final prompt = """
      Genera un único reto creativo y motivador para un usuario interesado en: $preferredTypesString.
      El reto debe ser realizable en un solo día.
      Responde EXCLUSIVAMENTE como un objeto JSON válido con las siguientes claves:
      - "title": string (título corto con emoji).
      - "description": string (descripción de 1-2 frases).
      - "type": string (una de las categorías proporcionadas: $preferredTypesString).
      - "isTimerBased": boolean (true si el reto requiere un temporizador, de lo contrario false).
      - "durationInMinutes": int (si isTimerBased es true, la duración en minutos del temporizador. Si no, 0).
      - "intervalInMinutes": int (si el reto se repite, el intervalo en minutos. Si no se repite, 0).

      **REGLA IMPORTANTE:** Si un reto consiste en varias actividades con tiempo (ej: 20 min de lectura y 10 de meditación), DEBES establecer "isTimerBased" en true y "durationInMinutes" DEBE SER LA SUMA TOTAL de todos los tiempos (ej: 30).

      Ejemplo de reto con tiempo SUMADO:
      {
        "title": "Triada de Bienestar 🧘📖",
        "description": "Combina 20 minutos de lectura, 20 de ejercicio y 10 de meditación.",
        "type": "mindfulness",
        "isTimerBased": true,
        "durationInMinutes": 50,
        "intervalInMinutes": 0
      }
      
      Ejemplo de reto con tiempo único:
      {
        "title": "Lectura Profunda 📚",
        "description": "Lee un libro durante 25 minutos sin ninguna distracción.",
        "type": "reading",
        "isTimerBased": true,
        "durationInMinutes": 25,
        "intervalInMinutes": 0
      }
      
      Ejemplo para un reto sin tiempo:
      {
        "title": "Agradecimiento Diario 🙏",
        "description": "Escribe tres cosas por las que te sientas agradecido hoy.",
        "type": "mindfulness",
        "isTimerBased": false,
        "durationInMinutes": 0,
        "intervalInMinutes": 0
      }
      """;

      final response = await _model.generateContent([Content.text(prompt)]);
      
      final cleanedResponse = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonResponse = jsonDecode(cleanedResponse);

      return Challenge.fromJson({
        ...jsonResponse,
        "id": "challenge_${today.year}_${today.month}_${today.day}",
        "date": today.toIso8601String(), 
      });

    } catch (e) {
      print('Error al llamar a la API de Gemini: $e');
      return _getFallbackChallenge(today, preferredTypes.first);
    }
  }
  
  Challenge _getFallbackChallenge(DateTime date, String type) {
    return Challenge(
      id: "fallback_${date.year}_${date.month}_${date.day}",
      title: "Reto de Respaldo ⚙️",
      description: "La conexión falló. Intenta meditar por 5 minutos.",
      type: type,
      date: date,
      isTimerBased: true,
      durationInMinutes: 5,
      intervalInMinutes: 0,
    );
  }
}