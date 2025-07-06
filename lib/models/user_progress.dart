// lib/models/user_progress.dart

class UserProgress {
  final Set<String> completedChallengeIds;
  final Set<String> unlockedBadgeIds;
  final Set<String> preferredChallengeTypes; // CAMBIADO: de ChallengeType a String

  UserProgress({
    required this.completedChallengeIds,
    required this.unlockedBadgeIds,
    required this.preferredChallengeTypes,
  });
}