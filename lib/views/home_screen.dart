// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../controllers/challenge_controller.dart';

// --- NUEVO: Stateful widget para manejar la selección del interés ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedInterest;

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para que la UI se reconstruya con los cambios del controller
    final controller = context.watch<ChallengeController>();
    final interests = controller.userProgress?.preferredChallengeTypes.toList() ?? [];

    // Sincroniza la lista de intereses con el dropdown
    if (_selectedInterest != null && !interests.contains(_selectedInterest)) {
      _selectedInterest = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reto del Día 💪'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // El botón de refrescar ahora limpia la selección para elegir de nuevo
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
                ? const CircularProgressIndicator()
                // --- LÓGICA DE VISTA MODIFICADA ---
                : controller.dailyChallenge == null
                    ? _buildInterestSelector(context, controller, interests) // Muestra el selector
                    : _buildChallengeCard(context, controller), // Muestra el reto
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

  // --- NUEVO WIDGET: Selector de intereses ---
  Widget _buildInterestSelector(BuildContext context, ChallengeController controller, List<String> interests) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Elige una categoría para tu reto:',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Dropdown para seleccionar el interés
          if (interests.isNotEmpty)
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedInterest,
              hint: const Text('Seleccionar interés'),
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.psychology),
            label: const Text('Generar Reto'),
            onPressed: _selectedInterest == null
                ? null // Deshabilitado si no hay interés seleccionado
                : () => controller.getChallengeForType(_selectedInterest!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET EXISTENTE: Tarjeta del reto ---
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
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
    );
  }

  // Widget para los botones de acción (completar, iniciar, etc.)
  Widget _buildActionButton(BuildContext context, ChallengeController controller) {
    if (controller.isChallengeCompletedToday) {
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
      final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      return Column(
        children: [
          Text(timeString, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: controller.timerRemainingSeconds / (controller.dailyChallenge!.durationInMinutes * 60),
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