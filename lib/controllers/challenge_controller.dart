// lib/controllers/challenge_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/challenge.dart';
import '../models/user_progress.dart';
import '../services/challenge_service.dart';
import '../services/storage_service.dart';

class ChallengeController with ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();
  final StorageService _storageService = StorageService();
  final _backgroundService = FlutterBackgroundService();

  Challenge? _dailyChallenge;
  UserProgress? _userProgress;
  bool _isLoading = true;
  bool _isChallengeCompletedToday = false;
  late ConfettiController confettiController;

  // --- ESTADOS DEL TEMPORIZADOR AÑADIDOS ---
  bool _isTimerRunning = false;
  int _timerRemainingSeconds = 0;

  Challenge? get dailyChallenge => _dailyChallenge;
  UserProgress? get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  bool get isChallengeCompletedToday => _isChallengeCompletedToday;
  bool get isTimerRunning => _isTimerRunning;
  int get timerRemainingSeconds => _timerRemainingSeconds;

  ChallengeController() {
    confettiController = ConfettiController(duration: const Duration(seconds: 1));
    loadInitialData();
    _backgroundService.on('update').listen(_onTimerUpdate);
    _backgroundService.on('timer_finished').listen(_onTimerFinished);
  }

  // Escucha los ticks del temporizador desde el servicio
  void _onTimerUpdate(Map<String, dynamic>? event) {
    if (event != null) {
      _timerRemainingSeconds = event['remaining_seconds'];
      _isTimerRunning = true;
      notifyListeners();
    }
  }

  // Escucha cuando el temporizador termina
  void _onTimerFinished(Map<String, dynamic>? event) {
    _isTimerRunning = false;
    _timerRemainingSeconds = 0;
    // La lógica de intervalo/completar se maneja aquí
    // Por ahora, simplemente lo marcamos como completado
    completeChallenge(); 
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    _userProgress = await _storageService.loadUserProgress();
    _dailyChallenge = await _challengeService.getDailyChallenge(_userProgress!.preferredChallengeTypes);

    if (_dailyChallenge != null) {
      _isChallengeCompletedToday = _userProgress!.completedChallengeIds.contains(_dailyChallenge!.id);
    }
    
    // Comprobar si un servicio ya está corriendo
    final isRunning = await _backgroundService.isRunning();
    _isTimerRunning = isRunning;

    _isLoading = false;
    notifyListeners();
  }
  
  // --- NUEVOS MÉTODOS PARA EL TEMPORIZADOR ---

  void startChallengeTimer() {
    if (_dailyChallenge == null || !_dailyChallenge!.isTimerBased) return;
    final durationInSeconds = _dailyChallenge!.durationInMinutes * 60;
    _backgroundService.startService();
    _backgroundService.invoke('startTimer', {
      'durationInSeconds': durationInSeconds,
    });
    _isTimerRunning = true;
    _timerRemainingSeconds = durationInSeconds;
    notifyListeners();
  }

  void stopChallengeTimer() {
    _backgroundService.invoke('stopService');
    _isTimerRunning = false;
    _timerRemainingSeconds = 0;
    notifyListeners();
  }

  // --- MÉTODOS EXISTENTES MODIFICADOS/SIN CAMBIOS ---

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
    // Ya no detenemos el servicio aquí para que siga en background
    confettiController.dispose();
    super.dispose();
  }
}