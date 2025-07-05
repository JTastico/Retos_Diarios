// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../controllers/challenge_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el controlador usando Provider
    final controller = Provider.of<ChallengeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reto del Día 💪'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // --- INICIO DEL CÓDIGO AÑADIDO ---
          // Botón para refrescar y obtener un nuevo reto
          // Se deshabilita mientras está cargando para evitar múltiples peticiones
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.isLoading
                ? null // Si está cargando, el botón no hace nada
                : () {
                    // Muestra una notificación temporal
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Buscando un nuevo reto...'),
                        backgroundColor: Colors.blueAccent,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    // Llama a la función para cargar un nuevo reto
                    controller.loadInitialData();
                  },
            tooltip: 'Obtener otro reto',
          ),
          // --- FIN DEL CÓDIGO AÑADIDO ---
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            // Si está cargando, muestra una rueda de progreso
            child: controller.isLoading
                ? const CircularProgressIndicator()
                // Si no hay reto (por un error), muestra un mensaje
                : controller.dailyChallenge == null
                    ? const Text('No se pudo cargar el reto.')
                    // Si todo está bien, muestra la tarjeta del reto
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
                            // Botón para marcar el reto como completado
                            ElevatedButton.icon(
                              onPressed: controller.isChallengeCompletedToday
                                  ? null // Deshabilitado si ya se completó
                                  : () => controller.completeChallenge(),
                              icon: Icon(controller.isChallengeCompletedToday
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline),
                              label: Text(controller.isChallengeCompletedToday
                                  ? '¡Reto Completado!'
                                  : 'Marcar como Completado'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
          // Widget para la animación de confeti
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
}