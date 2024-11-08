import 'package:flutter/material.dart';
import 'package:phrazy/game_widgets/card_style.dart';
import 'package:phrazy/utility/style.dart';
import '../data/puzzle.dart';
import '../game_widgets/grid.dart';

class GuesserWordbank extends StatelessWidget {
  const GuesserWordbank({
    super.key,
    required this.bank,
  });

  final List<String> bank;

  @override
  Widget build(BuildContext context) {
    return PhrazyCard(
      color: Style.textColor,
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
