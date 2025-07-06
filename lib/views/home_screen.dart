// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart'; // Asegúrate que el paquete está en pubspec.yaml
import 'package:retos_diarios_app/controllers/challenge_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChallengeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reto del Día 💪'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.isLoading || controller.isTimerRunning
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Buscando un nuevo reto...'),
                        backgroundColor: Colors.blueAccent,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    controller.loadInitialData();
                  },
            tooltip: 'Obtener otro reto',
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: controller.isLoading
                ? const CircularProgressIndicator()
                : controller.dailyChallenge == null
                    ? const Text('No se pudo cargar el reto.')
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tu reto de hoy:',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Text(
                                      controller.dailyChallenge!.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      controller.dailyChallenge!.description,
                                      style: Theme.of(context).textTheme.bodyLarge,
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
                      ),
          ),
          ConfettiWidget(
            confettiController: controller.confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 20,
            gravity: 0.1,
            emissionFrequency: 0.05,
            colors: const [
              Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
            ],
          ),
        ],
      ),
    );
  }

  // Widget helper para decidir qué botón o indicador mostrar
  Widget _buildActionButton(BuildContext context, ChallengeController controller) {
    if (controller.isChallengeCompletedToday) {
      // CORRECCIÓN: Se eliminó "const" de la siguiente línea
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle),
        label: const Text('¡Reto Completado!'),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.green,
          disabledForegroundColor: Colors.white,
        ),
      );
    }

    if (controller.isTimerRunning) {
      final minutes = (controller.timerRemainingSeconds / 60).floor();
      final seconds = controller.timerRemainingSeconds % 60;
      final timeString =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      return Column(
        children: [
          Text(timeString, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: controller.timerRemainingSeconds /
                (controller.dailyChallenge!.durationInMinutes * 60),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => controller.stopChallengeTimer(),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
          textStyle: const TextStyle(fontSize: 18),
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
          textStyle: const TextStyle(fontSize: 18),
        ),
      );
    }
  }
}
