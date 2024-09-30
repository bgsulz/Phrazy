import 'package:flutter/material.dart';
import 'package:phrasewalk/game_widgets/interaction.dart';
import 'package:phrasewalk/state.dart';
import 'package:provider/provider.dart';
import '../data/puzzle.dart';
import '../game_widgets/grid.dart';

class GuesserSolveGrid extends StatelessWidget {
  const GuesserSolveGrid(
      {required this.columnCount, required this.grid, super.key});

  final int columnCount;
  final List<TileData> grid;

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);

    final columnCount = gameState.loadedPuzzle.columns;
    final itemHeight = 240 / columnCount;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GuesserWordGrid(
            itemCount: grid.length,
            columnCount: columnCount,
            itemHeight: itemHeight,
            builder: (index) {
              return GuesserGridTile(
                  data: grid[index],
                  position: GridPosition(index: index, isWordBank: false));
            },
          ),
          GuesserWordGrid(
            itemCount: grid.length,
            columnCount: columnCount,
            itemHeight: itemHeight,
            builder: (index) {
              return GuesserTileOverlay(
                data: grid[index],
              );
            },
          ),
          GuesserWordGrid(
            itemCount: grid.length,
            columnCount: columnCount,
            itemHeight: itemHeight,
            builder: (index) {
              return GuesserInteractionOverlay(
                interaction: gameState.interactionState[index],
              );
            },
          ),
        ],
      ),
    );
  }
}

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
