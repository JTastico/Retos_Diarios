// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../controllers/challenge_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedInterest;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChallengeController>();
    final interests = controller.userProgress?.preferredChallengeTypes.toList() ?? [];

    if (_selectedInterest != null && !interests.contains(_selectedInterest)) {
      _selectedInterest = null;
    }

    return Scaffold(
      appBar: AppBar(
        // --- ESTILO MODIFICADO ---
        title: const Text('Reto del Día 💪'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.isLoading || controller.isTimerRunning
                ? null
                : () {
                    setState(() {
                      _selectedInterest = null;
                    });
                    controller.clearChallenge();
                  },
            tooltip: 'Elegir otro tipo de reto',
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: controller.isLoading
                ? const CircularProgressIndicator(color: Colors.amber)
                : controller.dailyChallenge == null
                    ? _buildInterestSelector(context, controller, interests)
                    : _buildChallengeCard(context, controller),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: controller.confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              gravity: 0.2,
              emissionFrequency: 0.05,
              colors: const [
                Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestSelector(BuildContext context, ChallengeController controller, List<String> interests) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Elige una categoría para tu reto:',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (interests.isNotEmpty)
            // --- ESTILO MODIFICADO ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedInterest,
                hint: const Text('Seleccionar interés'),
                dropdownColor: const Color(0xFF3a2d5c),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                underline: const SizedBox(),
                items: interests.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedInterest = newValue;
                  });
                },
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.psychology),
            label: const Text('Generar Reto'),
            onPressed: _selectedInterest == null
                ? null
                : () => controller.getChallengeForType(_selectedInterest!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, ChallengeController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tu reto de "${controller.dailyChallenge!.type}":',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Card(
            // El estilo de la Card se toma del tema global en main.dart
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    controller.dailyChallenge!.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.dailyChallenge!.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.8)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildActionButton(context, controller),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ChallengeController controller) {
    if (controller.isChallengeCompletedToday) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle),
        label: const Text('¡Reto Completado!'),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.green.withOpacity(0.8),
          disabledForegroundColor: Colors.white,
        ),
      );
    }

    if (controller.isTimerRunning) {
      final minutes = (controller.timerRemainingSeconds / 60).floor();
      final seconds = controller.timerRemainingSeconds % 60;
      final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      return Column(
        children: [
          Text(timeString, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: controller.timerRemainingSeconds / (controller.dailyChallenge!.durationInMinutes * 60),
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => controller.stopChallengeTimer(),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
        ],
      );
    }

    if (controller.dailyChallenge!.isTimerBased) {
      return ElevatedButton.icon(
        onPressed: () => controller.startChallengeTimer(),
        icon: const Icon(Icons.timer),
        label: const Text('Iniciar Reto'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () => controller.completeChallenge(),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Marcar como Completado'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}