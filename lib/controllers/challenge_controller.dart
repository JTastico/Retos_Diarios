// lib/controllers/challenge_controller.dart

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/challenge.dart';
import '../models/user_progress.dart';
import '../services/challenge_service.dart';
import '../services/storage_service.dart';

class ChallengeController with ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();
  final StorageService _storageService = StorageService();

  Challenge? _dailyChallenge;
  UserProgress? _userProgress;
  bool _isLoading = true;
  bool _isChallengeCompletedToday = false;
  late ConfettiController confettiController;

  Challenge? get dailyChallenge => _dailyChallenge;
  UserProgress? get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  bool get isChallengeCompletedToday => _isChallengeCompletedToday;

  ChallengeController() {
    confettiController = ConfettiController(duration: const Duration(seconds: 1));
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    _userProgress = await _storageService.loadUserProgress();
    
    // Pasamos las preferencias del usuario al servicio
    _dailyChallenge = await _challengeService.getDailyChallenge(_userProgress!.preferredChallengeTypes);

    if (_dailyChallenge != null) {
      _isChallengeCompletedToday = _userProgress!.completedChallengeIds.contains(_dailyChallenge!.id);
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> updatePreferredTypes(Set<ChallengeType> newTypes) async {
      if (_userProgress == null) return;
      _userProgress = UserProgress(
        completedChallengeIds: _userProgress!.completedChallengeIds,
        unlockedBadgeIds: _userProgress!.unlockedBadgeIds,
        preferredChallengeTypes: newTypes,
      );
      await _storageService.saveUserProgress(_userProgress!);
      notifyListeners();
  }

  Future<void> completeChallenge() async {
    if (_dailyChallenge == null || _userProgress == null || _isChallengeCompletedToday) return;

    _userProgress!.completedChallengeIds.add(_dailyChallenge!.id);
    _isChallengeCompletedToday = true;
    
    _checkAndUnlockBadges();

    await _storageService.saveUserProgress(_userProgress!);
    
    confettiController.play();
    notifyListeners();
  }
  
  void _checkAndUnlockBadges() {
    if (_userProgress!.completedChallengeIds.length == 1) {
      _userProgress!.unlockedBadgeIds.add('first_challenge');
    }
    if (_userProgress!.completedChallengeIds.length >= 5) {
       _userProgress!.unlockedBadgeIds.add('five_day_streak');
    }
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }
}