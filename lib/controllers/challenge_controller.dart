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
    // MODIFICADO: Solo carga los datos del usuario, no el reto.
    loadUserData(); 
    _backgroundService.on('update').listen(_onTimerUpdate);
    _backgroundService.on('timer_finished').listen(_onTimerFinished);
  }

  // --- MÉTODOS MODIFICADOS Y NUEVOS ---

  // 1. Carga solo los datos del usuario, sin buscar un reto.
  Future<void> loadUserData() async {
    _isLoading = true;
    _dailyChallenge = null; // Resetea el reto al cargar
    notifyListeners();

    _userProgress = await _storageService.loadUserProgress();
    
    final isRunning = await _backgroundService.isRunning();
    _isTimerRunning = isRunning;
    
    _isLoading = false;
    notifyListeners();
  }
  
  // 2. NUEVO: Busca un reto para un interés específico.
  Future<void> getChallengeForType(String interest) async {
    if (_userProgress == null) return;
    
    _isLoading = true;
    notifyListeners();

    // Llama al servicio con un Set que contiene solo el interés seleccionado.
    _dailyChallenge = await _challengeService.getDailyChallenge({interest});

    if (_dailyChallenge != null) {
      _isChallengeCompletedToday = _userProgress!.completedChallengeIds.contains(_dailyChallenge!.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  // 3. NUEVO: Limpia el reto actual para permitir una nueva selección.
  void clearChallenge() {
    _dailyChallenge = null;
    notifyListeners();
  }

  // --- MÉTODOS EXISTENTES (sin cambios en su lógica interna) ---

  void _onTimerUpdate(Map<String, dynamic>? event) {
    if (event != null) {
      _timerRemainingSeconds = event['remaining_seconds'];
      _isTimerRunning = true;
      notifyListeners();
    }
  }

  void _onTimerFinished(Map<String, dynamic>? event) {
    _isTimerRunning = false;
    _timerRemainingSeconds = 0;
    completeChallenge();
    notifyListeners();
  }

  void startChallengeTimer() {
    if (_dailyChallenge == null || !_dailyChallenge!.isTimerBased) return;
    final durationInSeconds = _dailyChallenge!.durationInMinutes * 60;
    _backgroundService.startService();
    _backgroundService.invoke('startTimer', {'durationInSeconds': durationInSeconds});
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

  Future<void> updatePreferredTypes(Set<String> newTypes) async {
    if (_userProgress == null) return;
    _userProgress = UserProgress(
      completedChallengeIds: _userProgress!.completedChallengeIds,
      unlockedBadgeIds: _userProgress!.unlockedBadgeIds,
      preferredChallengeTypes: newTypes,
    );
    await _storageService.saveUserProgress(_userProgress!);
    notifyListeners();
  }

  Future<void> addInterest(String interest) async {
    if (_userProgress == null || interest.trim().isEmpty) return;
    final newPrefs = Set<String>.from(_userProgress!.preferredChallengeTypes)..add(interest.trim());
    await updatePreferredTypes(newPrefs);
  }

  Future<void> editInterest(String oldInterest, String newInterest) async {
    if (_userProgress == null || newInterest.trim().isEmpty) return;
    final newPrefs = Set<String>.from(_userProgress!.preferredChallengeTypes);
    if (newPrefs.contains(oldInterest)) {
      newPrefs.remove(oldInterest);
      newPrefs.add(newInterest.trim());
      await updatePreferredTypes(newPrefs);
    }
  }

  Future<void> deleteInterest(String interest) async {
    if (_userProgress == null || _userProgress!.preferredChallengeTypes.length <= 1) return;
    final newPrefs = Set<String>.from(_userProgress!.preferredChallengeTypes)..remove(interest);
    await updatePreferredTypes(newPrefs);
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