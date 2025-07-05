// lib/models/user_progress.dart

class UserProgress {
  final Set<String> completedChallengeIds;
  final Set<String> unlockedBadgeIds;

  UserProgress({
    required this.completedChallengeIds,
    required this.unlockedBadgeIds,
  });
}