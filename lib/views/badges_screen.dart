// lib/views/badges_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../controllers/challenge_controller.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  final Map<String, String> allBadges = const {
    'first_challenge': 'Primer Reto',
    'five_day_streak': 'Racha de 5 Días',
  };

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChallengeController>(context);
    final unlockedBadges = controller.userProgress?.unlockedBadgeIds ?? {};

    return Scaffold(
      appBar: AppBar(
        // --- ESTILO MODIFICADO ---
        title: const Text('Mis Insignias 🏆'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columnas para más espacio
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1, // Relación de aspecto cuadrada
        ),
        itemCount: allBadges.length,
        itemBuilder: (context, index) {
          final badgeId = allBadges.keys.elementAt(index);
          final badgeName = allBadges.values.elementAt(index);
          final isUnlocked = unlockedBadges.contains(badgeId);

          // --- TARJETA DE INSIGNIA MODIFICADA ---
          return Container(
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isUnlocked ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.2),
              ),
              boxShadow: isUnlocked ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ] : [],
            ),
            child: Opacity(
              opacity: isUnlocked ? 1.0 : 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset('assets/badges/$badgeId.svg'),
                    ),
                  ),
                  Text(
                    badgeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}