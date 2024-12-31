import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/game_widgets/interactions/interaction_direction.dart';
import 'package:phrazy/game_widgets/widget_knob.dart';
import 'package:phrazy/utility/style.dart';

class InteractionX extends StatelessWidget {
  const InteractionX({
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
