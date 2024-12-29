import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/data/phrasetail.dart';
import 'package:phrazy/utility/style.dart';
import '../state/state.dart';

enum InteractionDirection { right, down }

class PhrazyKnob extends StatelessWidget {
  const PhrazyKnob({
    super.key,
    required this.direction,
    required this.interaction,
    required this.cardSize,
  });

  final InteractionDirection direction;
  final Interaction interaction;
  final BoxConstraints cardSize;

  factory PhrazyKnob.right(Tail tail, Size cardSize) {
    return PhrazyKnob(
      direction: InteractionDirection.right,
      interaction: Interaction(tailRight: tail),
      cardSize: BoxConstraints.tight(cardSize),
    );
  }

  factory PhrazyKnob.down(Tail tail, Size cardSize) {
    return PhrazyKnob(
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

class PhrazyX extends StatelessWidget {
  const PhrazyX({
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
              HugeIcons.strokeRoundedCancel02,
              color: Style.noColor,
            ),
          ),
        ),
      ),
    );
  }
}
