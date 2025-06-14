import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:phrazy/utility/style.dart';

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
          colors: const [
            Style.yesColor,
            Style.noColor,
            Style.cardColor,
            Style.backgroundColor,
            Style.textColor,
            Style.backgroundColorLight,
          ],
        ),
      ),
    );
  }
}
