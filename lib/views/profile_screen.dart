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
            // --- ESTILO MODIFICADO ---
            title: const Text('Mis Intereses 🎯'),
            backgroundColor: Colors.transparent,
            elevation: 0,
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
              ? const Center(child: CircularProgressIndicator(color: Colors.amber))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Gestiona las categorías de retos que te gustaría recibir:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white.withOpacity(0.9)),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: interests.length,
                        itemBuilder: (context, index) {
                          final interest = interests[index];
                          // --- ESTILO MODIFICADO ---
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.label_important_outline, color: Colors.amber),
                              title: Text(interest, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.white.withOpacity(0.7)),
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
                            ),
                          );
                        },
                      ),
                    ),
                    // --- BOTÓN DE CERRAR SESIÓN MODIFICADO ---
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                          onPressed: () async {
                             await controller.signOut();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.redAccent.withOpacity(0.5))
                            )
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showInterestDialog(BuildContext context, ChallengeController controller, {String? existingInterest}) {
    final textController = TextEditingController(text: existingInterest);
    final isEditing = existingInterest != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          // --- ESTILO MODIFICADO ---
          backgroundColor: const Color(0xFF2c2141),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(isEditing ? 'Editar Interés' : 'Añadir Interés'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nombre del interés',
              hintText: 'Ej: Fitness, Lectura, Cocina',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
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