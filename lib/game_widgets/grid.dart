import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:phrasewalk/data/puzzle.dart';
import 'package:phrasewalk/game_widgets/cards.dart';
import 'package:phrasewalk/state.dart';
import 'package:provider/provider.dart';

class GuesserWordGrid extends StatelessWidget {
  const GuesserWordGrid({
    required this.itemCount,
    required this.columnCount,
    required this.itemHeight,
    required this.builder,
    super.key,
  });

  final int itemCount;
  final int columnCount;
  final double itemHeight;
  final Widget Function(int) builder;

  @override
  Widget build(BuildContext context) {
    final rows = (itemCount / columnCount).ceil();

    return SizedBox(
      height: rows * itemHeight,
      child: LayoutGrid(
        columnSizes: repeat(columnCount, [1.fr]),
        rowSizes: repeat(rows, [1.fr]),
        children: List.generate(
            itemCount,
            (i) => SizedBox.expand(
                  child: builder(i),
                )),
      ),
    );
  }
}

class GridPosition {
  final int index;
  final bool isWordBank;

  const GridPosition({
    required this.index,
    required this.isWordBank,
  });
}

class GuesserGridTile extends StatelessWidget {
  const GuesserGridTile({
    super.key,
    required this.data,
    required this.position,
  });

  final TileData data;
  final GridPosition position;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<GameState>(
        builder: (context, state, child) {
          final word = state.wordOn(position);
          return DragTarget(
            onWillAcceptWithDetails: (data) => this.data != TileData.filled,
            onAcceptWithDetails: (data) {
              state.reportDrop(position, data.data as GridPosition);
            },
            builder: (context, candidateData, rejectedData) {
              return word.isEmpty
                  ? _buildEmptyCard(context, position.index)
                  : Draggable(
                      data: position,
                      feedback: WordCard(
                        word: word,
                        size: Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                      ),
                      childWhenDragging:
                          _buildEmptyCard(context, position.index),
                      child: GestureDetector(
                        onTap: () {
                          final appState =
                              Provider.of<GameState>(context, listen: false);
                          appState.reportClicked(position);
                        },
                        child: WordCard(word: word),
                      ),
                    );
            },
          );
        },
      );
    });
  }

  Widget _buildEmptyCard(BuildContext context, int index) {
    if (position.isWordBank) {
      return EmptyCard(
        color: Theme.of(context).colorScheme.surface,
        outlineColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    }
    return const EmptyCard();
  }
}
