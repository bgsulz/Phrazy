import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatelessWidget {
  final ConfettiController controller;

  const ConfettiOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: ConfettiWidget(
          numberOfParticles: 800,
          minBlastForce: 40,
          maxBlastForce: 150,
          blastDirectionality: BlastDirectionality.explosive,
          confettiController: controller,
          colors: [
            Theme.of(context).colorScheme.tertiary,
            Theme.of(context).colorScheme.error,
            Theme.of(context).colorScheme.surfaceContainerLow,
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.onSurface,
            Theme.of(context).colorScheme.surfaceBright,
          ],
        ),
      ),
    );
  }
}
