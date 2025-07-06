// lib/views/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/challenge_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeController>(
      builder: (context, controller, child) {
        final interests = controller.userProgress?.preferredChallengeTypes.toList() ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mis Intereses 🎯'),
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showInterestDialog(context, controller),
                tooltip: 'Añadir Interés',
              ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Gestiona las categorías de retos que te gustaría recibir:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: interests.length,
                        itemBuilder: (context, index) {
                          final interest = interests[index];
                          return ListTile(
                            leading: const Icon(Icons.label_important_outline),
                            title: Text(interest, style: const TextStyle(fontSize: 18)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () => _showInterestDialog(context, controller, existingInterest: interest),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    if (interests.length > 1) {
                                      controller.deleteInterest(interest);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Debes tener al menos un interés.')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // --- BOTÓN DE CERRAR SESIÓN ---
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                        onPressed: () async {
                           await controller.signOut();
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showInterestDialog(BuildContext context, ChallengeController controller, {String? existingInterest}) {
    // ... (El resto de este archivo no cambia)
    final textController = TextEditingController(text: existingInterest);
    final isEditing = existingInterest != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Interés' : 'Añadir Interés'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre del interés',
              hintText: 'Ej: Fitness, Lectura, Cocina',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final newInterest = textController.text.trim();
                if (newInterest.isNotEmpty) {
                  if (isEditing) {
                    controller.editInterest(existingInterest!, newInterest);
                  } else {
                    controller.addInterest(newInterest);
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}