import 'package:flutter/material.dart';
import 'package:phrasewalk/data/puzzle.dart';

class GuesserTileOverlay extends StatelessWidget {
  const GuesserTileOverlay({
    required this.data,
    super.key,
  });

  final TileData data;

  @override
  Widget build(BuildContext context) {
    final highlightColor = Theme.of(context).colorScheme.surfaceContainerLowest;
    const borderWidth = 4.0;
    final borderSide = BorderSide(color: highlightColor, width: borderWidth);

    final fillColor =
        data == TileData.filled ? highlightColor : Colors.transparent;
    final rightBorder = data == TileData.wallRight || data == TileData.wallBoth
        ? borderSide
        : BorderSide.none;
    final downBorder = data == TileData.wallDown || data == TileData.wallBoth
        ? borderSide
        : BorderSide.none;
    final border = data == TileData.filled
        ? Border.fromBorderSide(
            borderSide.copyWith(strokeAlign: BorderSide.strokeAlignCenter))
        : Border(
            right: rightBorder,
            bottom: downBorder,
          );

    final offset = data == TileData.filled
        ? Offset.zero
        : const Offset(borderWidth / 2, borderWidth / 2);

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
