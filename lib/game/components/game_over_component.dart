import 'package:flutter/material.dart';
import 'package:unicorn_crossing/l10n/l10n.dart';

class GameOverWidget extends StatelessWidget {
  const GameOverWidget({required this.onRestart, super.key});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Game Over Text
          Text(
            l10n.gameOver,
            style: const TextStyle(
              fontSize: 48,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20), // Spacing between text and button
          // Restart Button
          ElevatedButton(
            onPressed: onRestart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              l10n.restart,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
