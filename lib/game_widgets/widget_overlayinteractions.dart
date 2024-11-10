import 'package:flutter/material.dart';
import 'package:phrazy/game_widgets/widget_knob.dart';
import 'package:phrazy/state.dart';

class PhrazyInteractionGrid extends StatelessWidget {
  const PhrazyInteractionGrid({super.key, required this.interaction});
  final Interaction interaction;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            if (interaction.interactsDown)
              PhrazyKnob(
                direction: InteractionDirection.down,
                interaction: interaction,
                cardSize: constraints,
              )
            else if (interaction.tailDown.isFail)
              PhrazyX(
                  direction: InteractionDirection.down,
                  constraints: constraints),
            if (interaction.interactsRight)
              PhrazyKnob(
                direction: InteractionDirection.right,
                interaction: interaction,
                cardSize: constraints,
              )
            else if (interaction.tailRight.isFail)
              PhrazyX(
                  direction: InteractionDirection.right,
                  constraints: constraints),
          ],
        );
      }),
    );
  }
}
