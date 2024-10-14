import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phrazy/utility/style.dart';
import '../state.dart';

class GuesserInteractionOverlay extends StatelessWidget {
  const GuesserInteractionOverlay({super.key, required this.interaction});
  final PhraseInteraction interaction;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            if (interaction.interactsDown)
              GuesserInteractionKnob(
                direction: InteractionDirection.down,
                interaction: interaction,
                context: context,
                constraints: constraints,
              )
            else if (interaction.tailDown.isFail)
              GuesserX(
                  direction: InteractionDirection.down,
                  constraints: constraints),
            if (interaction.interactsRight)
              GuesserInteractionKnob(
                direction: InteractionDirection.right,
                interaction: interaction,
                context: context,
                constraints: constraints,
              )
            else if (interaction.tailRight.isFail)
              GuesserX(
                  direction: InteractionDirection.right,
                  constraints: constraints),
          ],
        );
      }),
    );
  }
}

enum InteractionDirection { right, down }

class GuesserInteractionKnob extends StatelessWidget {
  const GuesserInteractionKnob({
    super.key,
    required this.direction,
    required this.interaction,
    required this.context,
    required this.constraints,
  });

  final InteractionDirection direction;
  final PhraseInteraction interaction;
  final BuildContext context;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final width = min(constraints.maxWidth / 2.5, 36.0);
    final height = min(constraints.maxHeight / 2.5, 24.0);

    var offset = direction == InteractionDirection.down
        ? Offset(constraints.maxWidth / 2, constraints.maxHeight)
        : Offset(constraints.maxWidth, constraints.maxHeight / 2);

    var connector = direction == InteractionDirection.down
        ? interaction.tailDown.connector
        : interaction.tailRight.connector;
    if (connector.isEmpty) connector = Style.defaultConnector;

    return Transform.translate(
      offset: offset.translate(-width / 2, -height / 2),
      child: SizedBox(
        width: width,
        height: height,
        child: Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(128),
            ),
          ),
          color: Colors.greenAccent,
          child: Center(
            child: SelectionContainer.disabled(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    connector,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GuesserX extends StatelessWidget {
  const GuesserX({
    super.key,
    required this.direction,
    required this.constraints,
  });

  final InteractionDirection direction;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final width = constraints.maxWidth / 2.5;
    final height = constraints.maxHeight / 2.5;

    var offset = direction == InteractionDirection.down
        ? Offset(constraints.maxWidth / 2, constraints.maxHeight)
        : Offset(constraints.maxWidth, constraints.maxHeight / 2);

    return Transform.translate(
      offset: offset.translate(-width / 2, -height / 2),
      child: SizedBox(
        width: width,
        height: height,
        child: const Icon(
          Icons.cancel,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
