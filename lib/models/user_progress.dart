// lib/models/user_progress.dart

import 'challenge.dart';

class UserProgress {
  final Set<String> completedChallengeIds;
  final Set<String> unlockedBadgeIds;
  final Set<ChallengeType> preferredChallengeTypes;

  UserProgress({
    required this.completedChallengeIds,
    required this.unlockedBadgeIds,
    required this.preferredChallengeTypes,
  });
}