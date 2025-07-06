// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importar Supabase
import '../models/user_progress.dart';

class StorageService {
  // --- MODIFICADO: Las claves ahora son métodos que dependen del ID de usuario ---
  String _completedKey() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return 'completed_challenges_$userId';
  }

  String _badgesKey() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return 'unlocked_badges_$userId';
  }

  String _prefsKey() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return 'preferred_types_$userId';
  }

  Future<void> saveUserProgress(UserProgress progress) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return; // No guardar si no hay usuario

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey(), progress.completedChallengeIds.toList());
    await prefs.setStringList(_badgesKey(), progress.unlockedBadgeIds.toList());
    await prefs.setStringList(_prefsKey(), progress.preferredChallengeTypes.toList());
  }

  Future<UserProgress> loadUserProgress() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      // Devuelve un progreso vacío si no hay usuario
      return UserProgress(completedChallengeIds: {}, unlockedBadgeIds: {}, preferredChallengeTypes: {'fitness'});
    }

    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedKey()) ?? [];
    final badges = prefs.getStringList(_badgesKey()) ?? [];
    final preferences = prefs.getStringList(_prefsKey()) ?? [];
    
    if (preferences.isEmpty) {
        preferences.add('fitness');
    }

    return UserProgress(
      completedChallengeIds: completed.toSet(),
      unlockedBadgeIds: badges.toSet(),
      preferredChallengeTypes: preferences.toSet(),
    );
  }
}