import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/data/interaction.dart';
import 'package:phrazy/data/tail.dart';
import 'package:phrazy/game_widgets/interactions/interaction_direction.dart';
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
    final height = min(cardSize.maxHeight / 2.5, 36.0);

    final connectsDown = direction == InteractionDirection.down;
    final offset = connectsDown
        ? Offset(cardSize.maxWidth / 2, cardSize.maxHeight)
        : Offset(cardSize.maxWidth, cardSize.maxHeight / 2);

    final tail = connectsDown ? interaction.tailDown : interaction.tailRight;
    final connector = tail.connector;
    final shouldUseIcon = connector.isEmpty || connector == '-';

    return Stack(
      children: [
        CustomPaint(
          painter: LinePainter(
            context: context,
            direction: direction,
            cardSize: cardSize,
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
              color: Theme.of(context).colorScheme.tertiary,
              child: Center(
                child: SelectionContainer.disabled(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: shouldUseIcon
                        ? Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              HugeIcons.strokeRoundedLink05,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(1),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                connector
                                        .split(" ")
                                        .any((word) => word.length >= 3)
                                    ? connector.replaceAll(" ", "\n")
                                    : connector,
                                style: Style.bodySmall.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface,
                                    height: 1.1),
                                textAlign: TextAlign.center,
                                softWrap: true,
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

class LinePainter extends CustomPainter {
  final InteractionDirection direction;
  final BoxConstraints cardSize;
  final BuildContext context;

  LinePainter(
      {required this.context, required this.direction, required this.cardSize});

  @override
  void paint(Canvas canvas, Size size) {
    final connectsDown = direction == InteractionDirection.down;
    const lineThickness = 6.0;

    final start = connectsDown
        ? Offset(lineThickness / 2, cardSize.maxHeight)
        : Offset(cardSize.maxWidth, lineThickness / 2);
    final end = connectsDown
        ? Offset(cardSize.maxWidth - lineThickness / 2, cardSize.maxHeight)
        : Offset(cardSize.maxWidth, cardSize.maxHeight - lineThickness / 2);

    final paint = Paint()
      ..color = Theme.of(context).colorScheme.tertiary
      ..strokeWidth = lineThickness
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
