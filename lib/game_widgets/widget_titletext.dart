import 'package:flutter/material.dart';
import 'package:phrazy/utility/copy.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.compose(
            Vector3(0, 10, 0), Quaternion.euler(0, 0, -0.11), Vector3.all(1.2)),
        child: OverflowBox(
          maxHeight: double.infinity,
          child: FittedBox(
            child: Center(
              child: SelectionContainer.disabled(
                child: TextAnimator(
                  Copy.title,
                  incomingEffect:
                      WidgetTransitionEffects.incomingSlideInFromBottom(
                    curve: Curves.easeOutCirc,
                  ),
                  atRestEffect: WidgetRestingEffects.wave(
                    duration: const Duration(seconds: 3),
                    delay: const Duration(milliseconds: 500),
                    effectStrength: 5,
                    curve: Curves.easeInOutCirc,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontSize: 999,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -48,
                    fontVariations: const [FontVariation.weight(800)],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
