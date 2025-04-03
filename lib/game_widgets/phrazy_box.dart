import 'package:flutter/material.dart';
import '../utility/style.dart';

class PhrazyBox extends StatelessWidget {
  const PhrazyBox({
    super.key,
    this.elevation,
    this.rounded,
    this.borderRadius,
    this.outlineWidth,
    this.outlineColor,
    required this.child,
    required this.color,
  });

  final double? elevation;
  final bool? rounded;
  final double? outlineWidth;
  final Color? outlineColor;
  final Widget child;
  final Color color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    var radius =
        borderRadius ?? BorderRadius.circular((rounded ?? true) ? 16 : 1);

    return Material(
      borderRadius: radius,
      child: Container(
        clipBehavior: Clip.hardEdge,
        foregroundDecoration: BoxDecoration(
          border: outlineWidth != null && outlineWidth! <= 0
              ? null
              : Border.all(
                  width: outlineWidth ?? 4,
                  color: outlineColor ?? Style.textColor,
                ),
          borderRadius: radius,
        ),
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            BoxShadow(
                blurRadius: 0,
                color: Colors.black.withOpacity(0.25),
                offset: Offset(0, elevation ?? 8))
          ],
          borderRadius: radius,
        ),
        child: child,
      ),
    );
  }
}
