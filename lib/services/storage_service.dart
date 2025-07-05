// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class StorageService {
  static const _completedKey = 'completed_challenges';
  static const _badgesKey = 'unlocked_badges';

  Future<void> saveUserProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey, progress.completedChallengeIds.toList());
    await prefs.setStringList(_badgesKey, progress.unlockedBadgeIds.toList());
  }

  Future<UserProgress> loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedKey) ?? [];
    final badges = prefs.getStringList(_badgesKey) ?? [];
    return UserProgress(
      completedChallengeIds: completed.toSet(),
      unlockedBadgeIds: badges.toSet(),
    );
  }
}