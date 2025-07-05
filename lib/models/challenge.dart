// lib/models/challenge.dart

enum ChallengeType { fitness, reading, mindfulness }

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final DateTime date;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values.firstWhere((e) => e.toString() == 'ChallengeType.${json['type']}'),
      date: DateTime.parse(json['date']),
    );
  }
}