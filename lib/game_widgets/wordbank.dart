import 'package:flutter/material.dart';
import '../data/puzzle.dart';
import '../game_widgets/grid.dart';
import '../utility/style.dart';

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
