import 'package:flutter/material.dart';
import 'package:phrazy/data/phrasetail.dart';
import 'package:phrazy/data/puzzle.dart';
import 'package:phrazy/game_widgets/grid/phrazy_grid.dart';
import 'package:phrazy/game_widgets/widget_knob.dart';
import 'package:phrazy/game_widgets/widget_overlaywalls.dart';
import 'package:phrazy/game_widgets/widget_wordcard.dart';

class Demo extends StatelessWidget {
  static const double cardWidth = 160, cardHeight = 80;

  const Demo({super.key, required this.type});
  final int type;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: type == 1
          ? _demo1()
          : type == 2
              ? _demo2()
              : const SizedBox.shrink(),
    );
  }

  Widget _demo1() {
    const cardSize = Size(120, 60);
    const gridSize = (width: 3, height: 2);
    final gridCount = gridSize.width * gridSize.height;

    return SizedBox(
      width: cardSize.width * gridSize.width,
      child: Stack(children: [
        PhrazyGrid(
          itemCount: gridCount,
          columnCount: gridSize.width,
          itemHeight: cardSize.height,
          responsiveHeight: false,
          builder: (index) {
            if (index >= gridCount - 2) return const SizedBox.shrink();
            return WordCard(
              word: ['pillow', 'case', 'closed', 'fight'][index],
            );
          },
        ),
        PhrazyGrid(
            itemCount: gridCount,
            columnCount: gridSize.width,
            itemHeight: cardSize.height,
            responsiveHeight: false,
            builder: (index) {
              if (index == 0) {
                return Stack(
                  children: [
                    PhrazyKnob.right(Tail.from(''), cardSize),
                    PhrazyKnob.down(Tail.from(''), cardSize),
                  ],
                );
              }
              if (index == 1) {
                return PhrazyKnob.right(Tail.from(''), cardSize);
              }
              return const SizedBox.shrink();
            })
      ]),
    );
  }

  Widget _demo2() {
    const cardSize = Size(120, 60);
    const gridSize = (width: 2, height: 2);
    final gridCount = gridSize.width * gridSize.height;

    return SizedBox(
      width: cardSize.width * gridSize.width,
      child: Stack(children: [
        PhrazyGrid(
          itemCount: gridCount,
          columnCount: gridSize.width,
          itemHeight: cardSize.height,
          responsiveHeight: false,
          builder: (index) {
            return WordCard(
              word: ['bright', 'early', 'idea', 'bird'][index],
            );
          },
        ),
        PhrazyGrid(
          itemCount: gridCount,
          columnCount: gridSize.width,
          itemHeight: cardSize.height,
          responsiveHeight: false,
          builder: (index) {
            if (index == 2) {
              return const PhrazyWallOverlay(data: TileData.wallRight);
            }
            return const SizedBox.shrink();
          },
        ),
        PhrazyGrid(
            itemCount: gridCount,
            columnCount: gridSize.width,
            itemHeight: cardSize.height,
            responsiveHeight: false,
            builder: (index) {
              if (index == 0) {
                return Stack(
                  children: [
                    PhrazyKnob.right(
                      Tail.from('and early'),
                      cardSize,
                    ),
                    PhrazyKnob.down(Tail.from(''), cardSize),
                  ],
                );
              }
              if (index == 1) {
                return PhrazyKnob.down(Tail.from(''), cardSize);
              }
              return const SizedBox.shrink();
            })
      ]),
    );
  }
}
