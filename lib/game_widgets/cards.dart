import 'package:flutter/material.dart';
import '../utility/style.dart';

class EmptyCard extends StatelessWidget {
  final Color? color;
  final Color? outlineColor;

  const EmptyCard({
    super.key,
    this.color,
    this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      shape: Style.cardShape(
        outlineColor ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class WordCard extends StatelessWidget {
  final String word;
  final Size? size;

  const WordCard({required this.word, super.key, this.size});

  @override
  Widget build(BuildContext context) {
    var card = Card(
      elevation: size == null ? 2 : 16,
      margin: EdgeInsets.zero,
      shape: Style.cardShape(
        Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      color: Theme.of(context).colorScheme.onSurface,
      child: Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: SelectionContainer.disabled(
                child: Text(
              word,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              ),
            )),
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
