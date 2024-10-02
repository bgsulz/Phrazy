import 'package:flutter/material.dart';
import 'package:phrasewalk/data/puzzle.dart';
import 'package:phrasewalk/game_widgets/grid.dart';
import 'package:phrasewalk/utility/style.dart';

class GuesserWordbank extends StatelessWidget {
  const GuesserWordbank({
    super.key,
    required this.bank,
  });

  final List<String> bank;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: Style.cardShape(
          Theme.of(context).colorScheme.surfaceContainerHigh, 8),
      child: GuesserWordGrid(
        itemCount: bank.length,
        columnCount: 5,
        itemHeight: 320 / 5,
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
