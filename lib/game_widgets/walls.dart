import 'package:flutter/material.dart';
import '../data/puzzle.dart';

class GuesserTileOverlay extends StatelessWidget {
  const GuesserTileOverlay({
    required this.data,
    super.key,
  });

  final TileData data;

  @override
  Widget build(BuildContext context) {
    final highlightColor = Theme.of(context).colorScheme.surfaceContainerLowest;
    const borderWidth = 6.0;
    final borderSide = BorderSide(color: highlightColor, width: borderWidth);

    final isRight = data == TileData.wallRight || data == TileData.wallBoth;
    final isDown = data == TileData.wallDown || data == TileData.wallBoth;

    final fillColor =
        data == TileData.filled ? highlightColor : Colors.transparent;
    final rightBorder = isRight ? borderSide : BorderSide.none;
    final downBorder = isDown ? borderSide : BorderSide.none;
    final border = data == TileData.filled
        ? Border.fromBorderSide(
            borderSide.copyWith(strokeAlign: BorderSide.strokeAlignCenter))
        : Border(
            right: rightBorder,
            bottom: downBorder,
          );

    final offset = data == TileData.filled
        ? Offset.zero
        : Offset(isRight ? borderWidth / 2 : 0, isDown ? borderWidth / 2 : 0);

    return IgnorePointer(
        child: Transform.translate(
      offset: offset,
      child: Card(
          color: fillColor,
          shadowColor: Colors.transparent,
          margin: EdgeInsets.zero,
          shape: border),
    ));
  }
}
