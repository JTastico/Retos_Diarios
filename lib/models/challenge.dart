// lib/models/challenge.dart

enum ChallengeType { fitness, reading, mindfulness }

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final DateTime date;
  
  // --- CAMPOS AÑADIDOS ---
  final bool isTimerBased;
  final int durationInMinutes; // Duración de una sesión del temporizador
  final int intervalInMinutes; // Cada cuánto se repite (0 si no se repite)

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.isTimerBased = false,
    this.durationInMinutes = 0,
    this.intervalInMinutes = 0,
  });

  // Fábrica actualizada para manejar los nuevos campos
  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values.firstWhere((e) => e.name == json['type']),
      date: DateTime.parse(json['date']),
      isTimerBased: json['isTimerBased'] ?? false,
      durationInMinutes: json['durationInMinutes'] ?? 0,
      intervalInMinutes: json['intervalInMinutes'] ?? 0,
    );
  }
}