import 'package:flutter/material.dart';
import 'package:phrazy/game_widgets/grid_position.dart';
import 'package:phrazy/game_widgets/phrazy_box.dart';
import 'package:phrazy/game_widgets/grid/phrazy_tile.dart';
import 'package:phrazy/utility/style.dart';
import '../data/puzzle.dart';
import 'grid/phrazy_grid.dart';

class PhrazyWordbank extends StatelessWidget {
  const PhrazyWordbank({
    super.key,
    required this.bank,
  });

  final List<String> bank;

  @override
  Widget build(BuildContext context) {
    return PhrazyBox(
      color: Style.textColor,
      child: PhrazyGrid(
        itemCount: bank.length,
        columnCount: 5,
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
