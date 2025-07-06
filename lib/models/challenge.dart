// lib/models/challenge.dart

// ASEGÚRATE DE QUE EL ENUM 'ChallengeType' YA NO EXISTA EN ESTE ARCHIVO.

class Challenge {
  final String id;
  final String title;
  final String description;
  final String type; // Esto ahora es un String.
  final DateTime date;

  final bool isTimerBased;
  final int durationInMinutes;
  final int intervalInMinutes;

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

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      isTimerBased: json['isTimerBased'] ?? false,
      durationInMinutes: json['durationInMinutes'] ?? 0,
      intervalInMinutes: json['intervalInMinutes'] ?? 0,
    );
  }
}