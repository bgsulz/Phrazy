import 'package:flutter/material.dart';
import '../game_widgets/phrazy_box.dart';

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
    var card = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: PhrazyBox(
        elevation: size == null ? 0 : 16,
        outlineWidth: 1,
        outlineColor: Colors.grey.shade200,
        rounded: false,
        color: Theme.of(context).colorScheme.surfaceContainer,
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
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
