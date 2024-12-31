import '../game_widgets/grid_position.dart';
import '../game_widgets/phrazy_box.dart';
import '../game_widgets/grid/phrazy_tile.dart';
import '../game_widgets/widget_overlayinteractions.dart';
import '../utility/style.dart';

import 'widget_overlaywalls.dart';
import '../state/state.dart';
import '../data/puzzle.dart';
import 'grid/phrazy_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SolveGrid extends StatelessWidget {
  const SolveGrid({required this.puzzle, super.key});

  final Puzzle puzzle;

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final itemHeight = 320 / puzzle.columns;

    return PhrazyBox(
      color: Style.textColor,
      rounded: true,
      child: Stack(
        children: [
          PhrazyGrid(
            itemCount: puzzle.grid.length,
            columnCount: puzzle.columns,
            itemHeight: itemHeight,
            builder: (index) {
              return PhrazyTile(
                  data: puzzle.grid[index],
                  position: GridPosition(index: index, isWordBank: false));
            },
          ),
          if (!gameState.isPaused)
            PhrazyGrid(
              itemCount: puzzle.grid.length,
              columnCount: puzzle.columns,
              itemHeight: itemHeight,
              builder: (index) {
                return OverlayInteractionGrid(
                  interaction: gameState.interactionState[index],
                );
              },
            ),
          PhrazyGrid(
            itemCount: puzzle.grid.length,
            columnCount: puzzle.columns,
            itemHeight: itemHeight,
            builder: (index) {
              return OverlayWallGrid(
                data: puzzle.grid[index],
              );
            },
          ),
        ],
      ),
    );
  }
}
