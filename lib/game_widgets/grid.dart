import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:phrasewalk/data/puzzle.dart';
import 'package:phrasewalk/game_widgets/cards.dart';
import 'package:phrasewalk/sound.dart';
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

class GuesserGridTile extends StatefulWidget {
  const GuesserGridTile({
    super.key,
    required this.data,
    required this.position,
  });

  final TileData data;
  final GridPosition position;

  @override
  State<GuesserGridTile> createState() => _GuesserGridTileState();
}

class _GuesserGridTileState extends State<GuesserGridTile> {
  bool _aboutToAcceptDrop = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<GameState>(
        builder: (context, state, child) {
          final word = state.wordOn(widget.position);
          return DragTarget(
            onLeave: (data) {
              setState(() {
                _aboutToAcceptDrop = false;
              });
            },
            onWillAcceptWithDetails: (data) {
              if (state.isSolved) return false;
              var res = widget.data != TileData.filled;
              if (res) {
                setState(() {
                  if (!_aboutToAcceptDrop) {
                    playSound("rollover");
                  }
                  _aboutToAcceptDrop = true;
                });
              }
              return res;
            },
            onAcceptWithDetails: (data) {
              state.reportDrop(
                  widget.position, (data.data as CardDropData).position);
            },
            builder: (context, candidateData, rejectedData) {
              return word.isEmpty
                  ? _buildEmptyCard(context, widget.position.index)
                  : Draggable(
                      onDragStarted: () {
                        playSound("click");
                      },
                      maxSimultaneousDrags: state.isSolved ? 0 : null,
                      data: CardDropData(
                        size: Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                        position: widget.position,
                      ),
                      feedback: WordCard(
                        word: word,
                        size: Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                      ),
                      childWhenDragging:
                          _buildEmptyCard(context, widget.position.index),
                      child: GestureDetector(
                        onTap: () {
                          final appState =
                              Provider.of<GameState>(context, listen: false);
                          appState.reportClicked(widget.position);
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
    if (widget.position.isWordBank) {
      return EmptyCard(
        color: _aboutToAcceptDrop
            ? Theme.of(context).colorScheme.surfaceContainer
            : Theme.of(context).colorScheme.surface,
        outlineColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    }
    return EmptyCard(
      color:
          _aboutToAcceptDrop ? Theme.of(context).colorScheme.onSurface : null,
    );
  }
}

class CardDropData {
  final Size size;
  final GridPosition position;

  const CardDropData({required this.size, required this.position});
}
