import 'package:flutter/material.dart';
import 'package:phrasewalk/utility/style.dart';

class Demo extends StatelessWidget {
  static const double cardWidth = 160, cardHeight = 80;

  const Demo({super.key, required this.type});
  final int type;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: type == 1
          ? _demo1()
          : type == 2
              ? _demo2()
              : const SizedBox.shrink(),
    );
  }

  Stack _demo1() {
    return Stack(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DemoCard(text: "hello"),
                DemoCard(text: "world"),
                DemoCard(text: "map"),
              ],
            ),
            Row(
              children: [
                DemoCard(text: "dolly"),
              ],
            ),
          ],
        ),
        SizedBox(
          width: Demo.cardWidth * 3,
          height: Demo.cardHeight * 2,
          child: Center(
            child: Stack(
              children: [
                Transform.translate(
                  offset: const Offset(-Demo.cardWidth, 0),
                  child: const DemoKnob(text: "..."),
                ),
                Transform.translate(
                  offset:
                      const Offset(-Demo.cardWidth / 2, -Demo.cardHeight / 2),
                  child: const DemoKnob(text: "..."),
                ),
                Transform.translate(
                  offset:
                      const Offset(Demo.cardWidth / 2, -Demo.cardHeight / 2),
                  child: const DemoKnob(text: "..."),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Stack _demo2() {
    return Stack(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DemoCard(text: "order"),
                DemoCard(text: "court"),
              ],
            ),
            Row(
              children: [
                DemoCard(text: "meal"),
              ],
            ),
          ],
        ),
        SizedBox(
          width: Demo.cardWidth * 2,
          height: Demo.cardHeight * 2,
          child: Center(
            child: Stack(
              children: [
                Transform.translate(
                  offset: const Offset(0, -Demo.cardHeight / 2),
                  child: const DemoKnob(text: "in the"),
                ),
                Transform.translate(
                  offset: const Offset(-Demo.cardWidth / 2, 0),
                  child: const DemoKnob(text: "a"),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class DemoCard extends StatelessWidget {
  const DemoCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Demo.cardWidth,
      height: Demo.cardHeight,
      child: Card(
        margin: EdgeInsets.zero,
        shape: Style.cardShape(Theme.of(context).colorScheme.onSurface),
        elevation: 0,
        child: Center(
          child: SelectionContainer.disabled(
            child: Text(text),
          ),
        ),
      ),
    );
  }
}

class DemoKnob extends StatelessWidget {
  const DemoKnob({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Demo.cardWidth / 2.25,
      height: Demo.cardHeight / 2,
      child: Card(
        margin: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(128)),
        child: Center(
          child: SelectionContainer.disabled(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surfaceContainer,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }
}
