// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class StorageService {
  static const _completedKey = 'completed_challenges';
  static const _badgesKey = 'unlocked_badges';
  static const _prefsKey = 'preferred_types';

  Future<void> saveUserProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey, progress.completedChallengeIds.toList());
    await prefs.setStringList(_badgesKey, progress.unlockedBadgeIds.toList());
    await prefs.setStringList(_prefsKey, progress.preferredChallengeTypes.toList());
  }

  Future<UserProgress> loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedKey) ?? [];
    final badges = prefs.getStringList(_badgesKey) ?? [];
    final preferences = prefs.getStringList(_prefsKey) ?? [];
    
    // CORRECCIÓN CLAVE:
    // El código anterior convertía los strings a 'ChallengeType'.
    // Ahora, simplemente usamos la lista de strings directamente.
    
    if (preferences.isEmpty) {
        preferences.add('fitness');
    }

    return UserProgress(
      completedChallengeIds: completed.toSet(),
      unlockedBadgeIds: badges.toSet(),
      preferredChallengeTypes: preferences.toSet(), // Esto ahora crea correctamente un Set<String>
    );
  }
}