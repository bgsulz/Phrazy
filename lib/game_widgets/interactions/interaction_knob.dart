import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/data/tail.dart';
import 'package:phrazy/game_widgets/interactions/interaction_direction.dart';
import 'package:phrazy/game_widgets/widget_knob.dart';
import 'package:phrazy/state/state.dart';
import 'package:phrazy/utility/style.dart';

class InteractionKnob extends StatelessWidget {
  const InteractionKnob({
    super.key,
    required this.direction,
    required this.interaction,
    required this.cardSize,
  });

  final InteractionDirection direction;
  final Interaction interaction;
  final BoxConstraints cardSize;

  factory InteractionKnob.right(Tail tail, Size cardSize) {
    return InteractionKnob(
      direction: InteractionDirection.right,
      interaction: Interaction(tailRight: tail),
      cardSize: BoxConstraints.tight(cardSize),
    );
  }

  factory InteractionKnob.down(Tail tail, Size cardSize) {
    return InteractionKnob(
      direction: InteractionDirection.down,
      interaction: Interaction(tailDown: tail),
      cardSize: BoxConstraints.tight(cardSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = min(cardSize.maxWidth / 2.5, 36.0);
    final height = min(cardSize.maxHeight / 2.5, 24.0);

    final connectsDown = direction == InteractionDirection.down;
    const lineThickness = 6.0;
    final lineWidth = connectsDown ? cardSize.maxWidth : lineThickness;
    final lineHeight = !connectsDown ? cardSize.maxHeight : lineThickness;

    final offset = connectsDown
        ? Offset(cardSize.maxWidth / 2, cardSize.maxHeight)
        : Offset(cardSize.maxWidth, cardSize.maxHeight / 2);

    final tail = connectsDown ? interaction.tailDown : interaction.tailRight;
    final connector = tail.connector;
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
                          ? const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                HugeIcons.strokeRoundedLink05,
                                color: Style.textColor,
                              ),
                            )
                          : Text(
                              connector,
                              style: Style.bodySmall
                                  .copyWith(color: Style.textColor),
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
