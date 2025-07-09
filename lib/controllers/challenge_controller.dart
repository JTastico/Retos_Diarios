// lib/controllers/challenge_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// Ya no se necesita GoogleSignIn para el login, lo puedes quitar si no lo usas en otro lado.
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/challenge.dart';
import '../models/user_progress.dart';
import '../services/challenge_service.dart';
import '../services/storage_service.dart';

class ChallengeController with ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();
  final StorageService _storageService = StorageService();
  final _backgroundService = FlutterBackgroundService();
  final _supabase = Supabase.instance.client;

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
    loadUserData();
    _backgroundService.on('update').listen(_onTimerUpdate);
    _backgroundService.on('timer_finished').listen(_onTimerFinished);

    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        loadUserData();
      }
    });
  }

  // --- MÉTODOS DE AUTENTICACIÓN ---
  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    // El signOut de Supabase ahora se encarga de todo
    await _supabase.auth.signOut();
    _userProgress = null;
    _dailyChallenge = null;
    notifyListeners();
  }

  // --- MÉTODO DE GOOGLE SIGN-IN COMPLETAMENTE REEMPLAZADO ---
  Future<void> signInWithGoogle() async {
    // El bundle ID de tu app. Reemplaza 'com.example.retosDiariosApp' si es diferente.
    const appBundleId = 'com.example.retosDiariosApp';

    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      // redirectTo le dice a Supabase a dónde regresar después del login.
      // Debe ser tu esquema de URL personalizado.
      redirectTo: '$appBundleId://login-callback',
    );
  }


  // --- RESTO DE MÉTODOS DEL CONTROLADOR ---
  Future<void> loadUserData() async {
    if (_supabase.auth.currentUser == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    _dailyChallenge = null;
    notifyListeners();
    _userProgress = await _storageService.loadUserProgress();
    final isRunning = await _backgroundService.isRunning();
    _isTimerRunning = isRunning;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getChallengeForType(String interest) async {
    if (_userProgress == null) return;
    _isLoading = true;
    notifyListeners();
    _dailyChallenge = await _challengeService.getDailyChallenge({interest});
    if (_dailyChallenge != null) {
      _isChallengeCompletedToday = _userProgress!.completedChallengeIds.contains(_dailyChallenge!.id);
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearChallenge() {
    _dailyChallenge = null;
    notifyListeners();
  }

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