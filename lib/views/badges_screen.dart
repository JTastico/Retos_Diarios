// lib/views/badges_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../controllers/challenge_controller.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  // Mapa de insignias disponibles
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
        title: const Text('Mis Insignias 🏆'),
        backgroundColor: Colors.amber,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: allBadges.length,
        itemBuilder: (context, index) {
          final badgeId = allBadges.keys.elementAt(index);
          final badgeName = allBadges.values.elementAt(index);
          final isUnlocked = unlockedBadges.contains(badgeId);

          return Opacity(
            opacity: isUnlocked ? 1.0 : 0.3,
            child: Column(
              children: [
                Expanded(
                  child: SvgPicture.asset('lib/assets/badges/$badgeId.svg'),
                ),
                const SizedBox(height: 8),
                Text(
                  badgeName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}