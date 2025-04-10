import 'package:flutter/material.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../utility/style.dart';

class PhrazyBox extends StatelessWidget {
  const PhrazyBox({
    super.key,
    this.elevation,
    this.rounded,
    this.borderRadius,
    this.outlineWidth,
    this.outlineColor,
    this.shouldAnimate = false,
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
  final bool shouldAnimate;

  @override
  Widget build(BuildContext context) {
    var radius =
        borderRadius ?? BorderRadius.circular((rounded ?? true) ? 16 : 1);

    var material = Material(
      type:
          color.alpha == 255 ? MaterialType.canvas : MaterialType.transparency,
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
          boxShadow: null,
        ),
        decoration: BoxDecoration(
          color: color,
          boxShadow: elevation == 0
              ? null
              : [
                  BoxShadow(
                    blurRadius: 0,
                    color: Colors.black.withOpacity(0.25),
                    offset: Offset(0, elevation ?? 8),
                  )
                ],
          borderRadius: radius,
        ),
        child: child,
      ),
    );

    if (shouldAnimate) {
      return WidgetAnimator(
          incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(
            curve: Curves.easeOutCirc,
          ),
          child: material);
    } else {
      return material;
    }
  }
}
