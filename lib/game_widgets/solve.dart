import '../game_widgets/interaction.dart';
import '../game_widgets/walls.dart';
import '../state.dart';
import '../utility/style.dart';
import '../data/puzzle.dart';
import '../game_widgets/grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      shape: Style.cardShape(
          Theme.of(context).colorScheme.surfaceContainerHigh, 8),
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
