import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phrazy/utility/style.dart';
import '../state.dart';

enum InteractionDirection { right, down }

class PhrazyKnob extends StatelessWidget {
  const PhrazyKnob({
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

    final connectsDown = direction == InteractionDirection.down;
    const lineThickness = 6.0;
    final lineWidth = connectsDown ? constraints.maxWidth : lineThickness;
    final lineHeight = !connectsDown ? constraints.maxHeight : lineThickness;

    final offset = connectsDown
        ? Offset(constraints.maxWidth / 2, constraints.maxHeight)
        : Offset(constraints.maxWidth, constraints.maxHeight / 2);

    final connector = connectsDown
        ? interaction.tailDown.connector
        : interaction.tailRight.connector;
    final shouldUseIcon = connector.isEmpty || connector == '-';

    return Stack(
      children: [
        Transform.translate(
          offset: offset.translate(-lineWidth / 2, -lineHeight / 2),
          child: SizedBox(
            width: lineWidth,
            height: lineHeight,
            child: const Material(color: Style.yesColor),
          ),
        ),
        Transform.translate(
          offset: offset.translate(-width / 2, -height / 2),
          child: SizedBox(
            width: width,
            height: height,
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              color: Style.yesColor,
              child: Center(
                child: SelectionContainer.disabled(
                  child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: shouldUseIcon
                          ? Icon(
                              Icons.link,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
                            )
                          : Text(
                              connector,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
        child: const FittedBox(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.close,
              color: Style.noColor,
            ),
          ),
        ),
      ),
    );
  }
}
