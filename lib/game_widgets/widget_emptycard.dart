import 'package:flutter/material.dart';
import 'phrazy_box.dart';
import '../utility/style.dart';

class EmptyCard extends StatelessWidget {
  final Color color;
  final Color? outlineColor;

  const EmptyCard({
    super.key,
    required this.color,
    this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return PhrazyBox(
      rounded: false,
      outlineWidth: 1,
      outlineColor: Style.backgroundColorLight,
      color: color,
      child: const SizedBox.expand(),
    );
  }
}
