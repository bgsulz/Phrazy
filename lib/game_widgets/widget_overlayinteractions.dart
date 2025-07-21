import 'package:flutter/material.dart';
import 'package:phrazy/data/interaction.dart';
import 'package:phrazy/game_widgets/interactions/interaction_direction.dart';
import 'package:phrazy/game_widgets/interactions/interaction_knob.dart';
import 'package:phrazy/game_widgets/interactions/interaction_x.dart';

class OverlayInteractionGrid extends StatelessWidget {
  const OverlayInteractionGrid({super.key, required this.interaction});
  final Interaction interaction;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            if (interaction.interactsDown)
              InteractionKnob(
                direction: InteractionDirection.down,
                interaction: interaction,
                cardSize: constraints,
              )
            else if (interaction.tailDown.isFail)
              InteractionX(
                  direction: InteractionDirection.down,
                  constraints: constraints),
            if (interaction.interactsRight)
              InteractionKnob(
                direction: InteractionDirection.right,
                interaction: interaction,
                cardSize: constraints,
              )
            else if (interaction.tailRight.isFail)
              InteractionX(
                  direction: InteractionDirection.right,
                  constraints: constraints),
          ],
        );
      }),
    );
  }
}
