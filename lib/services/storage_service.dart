// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/challenge.dart';

class StorageService {
  static const _completedKey = 'completed_challenges';
  static const _badgesKey = 'unlocked_badges';
  static const _prefsKey = 'preferred_types';

  Future<void> saveUserProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey, progress.completedChallengeIds.toList());
    await prefs.setStringList(_badgesKey, progress.unlockedBadgeIds.toList());
    
    // Guardar las preferencias como una lista de strings
    final prefStrings = progress.preferredChallengeTypes.map((e) => e.name).toList();
    await prefs.setStringList(_prefsKey, prefStrings);
  }

  Future<UserProgress> loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedKey) ?? [];
    final badges = prefs.getStringList(_badgesKey) ?? [];
    final prefStrings = prefs.getStringList(_prefsKey) ?? [];
    
    // Cargar las preferencias y convertirlas de string a ChallengeType
    final preferences = prefStrings.map((name) {
      return ChallengeType.values.firstWhere((e) => e.name == name, orElse: () => ChallengeType.fitness);
    }).toSet();
    
    // Si no hay preferencias guardadas, se añade una por defecto.
    if (preferences.isEmpty) {
        preferences.add(ChallengeType.fitness);
    }

    return UserProgress(
      completedChallengeIds: completed.toSet(),
      unlockedBadgeIds: badges.toSet(),
      preferredChallengeTypes: preferences,
    );
  }
}