import 'package:flutter/material.dart';
import '../game_widgets/grid_position.dart';
import '../game_widgets/phrazy_box.dart';
import '../game_widgets/grid/phrazy_tile.dart';
import '../utility/style.dart';
import '../data/puzzle.dart';
import 'grid/phrazy_grid.dart';

class WordbankGrid extends StatelessWidget {
  const WordbankGrid({
    super.key,
    required this.bank,
  });

  final List<String> bank;

  @override
  Widget build(BuildContext context) {
    int columns;
    switch (MediaQuery.of(context).size.width) {
      case int width when width > 450:
        columns = 5;
        break;
      case int width when width > 375:
        columns = 4;
        break;
      default:
        columns = 3;
    }

    return PhrazyBox(
      shouldAnimate: true,
      color: Style.textColor,
      child: PhrazyGrid(
        itemCount: bank.length,
        columnCount: columns,
        itemHeight: 320 / 5,
        builder: (index) {
          return PhrazyTile(
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
