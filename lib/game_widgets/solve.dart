import 'package:phrazy/game_widgets/card_style.dart';
import 'package:phrazy/utility/style.dart';

import '../game_widgets/interaction.dart';
import '../game_widgets/walls.dart';
import '../state.dart';
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
    final itemHeight = 320 / columnCount;

    return PhrazyCard(
      color: Style.textColor,
      rounded: true,
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
          if (!gameState.isPaused)
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
        ],
      ),
    );
  }
}
