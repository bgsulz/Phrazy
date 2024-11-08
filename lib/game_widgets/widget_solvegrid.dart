import 'package:phrazy/game_widgets/grid_position.dart';
import 'package:phrazy/game_widgets/phrazy_box.dart';
import 'package:phrazy/game_widgets/grid/phrazy_tile.dart';
import 'package:phrazy/game_widgets/widget_overlayinteractions.dart';
import 'package:phrazy/utility/style.dart';

import 'widget_overlaywalls.dart';
import '../state.dart';
import '../data/puzzle.dart';
import 'grid/phrazy_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhrazySolveGrid extends StatelessWidget {
  const PhrazySolveGrid(
      {required this.columnCount, required this.grid, super.key});

  final int columnCount;
  final List<TileData> grid;

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final itemHeight = 320 / columnCount;

    return PhrazyBox(
      color: Style.textColor,
      rounded: true,
      child: Stack(
        children: [
          PhrazyGrid(
            itemCount: grid.length,
            columnCount: columnCount,
            itemHeight: itemHeight,
            builder: (index) {
              return PhrazyTile(
                  data: grid[index],
                  position: GridPosition(index: index, isWordBank: false));
            },
          ),
          if (!gameState.isPaused)
            PhrazyGrid(
              itemCount: grid.length,
              columnCount: columnCount,
              itemHeight: itemHeight,
              builder: (index) {
                return PhrazyInteractionGrid(
                  interaction: gameState.interactionState[index],
                );
              },
            ),
          PhrazyGrid(
            itemCount: grid.length,
            columnCount: columnCount,
            itemHeight: itemHeight,
            builder: (index) {
              return PhrazyWallOverlay(
                data: grid[index],
              );
            },
          ),
        ],
      ),
    );
  }
}
