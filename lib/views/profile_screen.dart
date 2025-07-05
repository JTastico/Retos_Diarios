// lib/views/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/challenge_controller.dart';
import '../models/challenge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para reconstruir solo la parte necesaria cuando cambian los datos
    return Consumer<ChallengeController>(
      builder: (context, controller, child) {
        final currentPrefs = controller.userProgress?.preferredChallengeTypes ?? {};

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mis Intereses 🎯'),
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecciona las categorías de retos que te gustaría recibir:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      // Generamos una lista de Checkbox para cada tipo de reto
                      ...ChallengeType.values.map((type) {
                        return CheckboxListTile(
                          title: Text(
                            '${_getEmojiForType(type)} ${type.name[0].toUpperCase()}${type.name.substring(1)}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          value: currentPrefs.contains(type),
                          onChanged: (bool? isSelected) {
                            if (isSelected == null) return;
                            
                            Set<ChallengeType> newPrefs = Set.from(currentPrefs);
                            if (isSelected) {
                              newPrefs.add(type);
                            } else {
                              // Evitar que el usuario deseleccione la última opción
                              if (newPrefs.length > 1) {
                                newPrefs.remove(type);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Debes tener al menos una categoría seleccionada.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                            controller.updatePreferredTypes(newPrefs);
                          },
                          activeColor: Colors.indigo,
                        );
                      }).toList(),
                       const Spacer(),
                       Center(
                         child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Generar Nuevo Reto'),
                            onPressed: () {
                              controller.loadInitialData(); // Vuelve a cargar los datos
                               ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Generando nuevo reto basado en tus intereses...'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                            ),
                          ),
                       ),
                       const SizedBox(height: 20),
                    ],
                  ),
                ),
        );
      },
    );
  }

  String _getEmojiForType(ChallengeType type) {
    switch (type) {
      case ChallengeType.fitness:
        return '🏋️';
      case ChallengeType.reading:
        return '📚';
      case ChallengeType.mindfulness:
        return '🧘';
    }
  }
}