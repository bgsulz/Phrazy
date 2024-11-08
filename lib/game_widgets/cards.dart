import 'package:flutter/material.dart';
import 'package:phrazy/game_widgets/card_style.dart';
import 'package:phrazy/utility/style.dart';

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
    return PhrazyCard(
      rounded: false,
      outlineWidth: 1,
      outlineColor: Style.backgroundColorLight,
      color: color,
      child: const SizedBox.shrink(),
    );
  }
}

class WordCard extends StatelessWidget {
  final String word;
  final Size? size;
  final bool hasMargins;

  const WordCard({
    required this.word,
    this.hasMargins = true,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var card = PhrazyCard(
      elevation: size == null ? 0 : 16,
      outlineWidth: 1,
      outlineColor: Colors.grey.shade200,
      rounded: false,
      color: Style.cardColor,
      child: Center(
        child: Padding(
          padding: hasMargins
              ? const EdgeInsets.symmetric(horizontal: 18, vertical: 12)
              : const EdgeInsets.all(4.0),
          child: SelectionContainer.disabled(
            child: FittedBox(
              child: Text(
                word,
                maxLines: 1,
                style: const TextStyle(
                  color: Style.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (size == null) return card;
    return SizedBox(
      width: size!.width,
      height: size!.height,
      child: card,
    );
  }
}
