import 'package:flutter/material.dart';
import 'package:phrasewalk/data/puzzle.dart';
import 'package:phrasewalk/game_widgets/grid.dart';
import 'package:phrasewalk/state.dart';
import 'package:phrasewalk/utility/style.dart';
import 'package:provider/provider.dart';

class GuesserWordbank extends StatelessWidget {
  const GuesserWordbank({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: Style.cardShape(
          Theme.of(context).colorScheme.surfaceContainerHigh, 8),
      child: GuesserWordGrid(
        itemCount: gameState.loadedPuzzle.words.length,
        columnCount: 5,
        itemHeight: 240 / 5,
        builder: (index) {
          return GuesserGridTile(
              data: TileData.empty,
              position: GridPosition(
                index: index,
                isWordBank: true,
              ));
        },
      ),
    );
  }
}
