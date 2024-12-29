import 'package:flutter/material.dart';
import 'package:phrazy/data/puzzle.dart';
import 'package:phrazy/game_widgets/grid_position.dart';
import 'package:phrazy/game_widgets/widget_emptycard.dart';
import 'package:phrazy/game_widgets/widget_wordcard.dart';
import 'package:phrazy/sound.dart';
import 'package:phrazy/state/state.dart';
import 'package:phrazy/utility/style.dart';
import 'package:provider/provider.dart';

class PhrazyTile extends StatefulWidget {
  const PhrazyTile({
    super.key,
    required this.data,
    required this.position,
  });

  final TileData data;
  final GridPosition position;

  @override
  State<PhrazyTile> createState() => _PhrazyTileState();
}

class _PhrazyTileState extends State<PhrazyTile> {
  bool _aboutToAcceptDrop = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<GameState>(
        builder: (context, state, child) {
          final word = state.wordAtPosition(widget.position);
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
              setState(() {
                _aboutToAcceptDrop = false;
              });
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
                      feedback: Transform.rotate(
                        angle: 0.1,
                        child: WordCard(
                          word: state.isPaused ? " " : word,
                          hasMargins: !widget.position.isWordBank,
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                        ),
                      ),
                      childWhenDragging:
                          _buildEmptyCard(context, widget.position.index),
                      child: GestureDetector(
                        onTap: () {
                          final gameState =
                              Provider.of<GameState>(context, listen: false);
                          gameState.reportClicked(widget.position);
                        },
                        child: WordCard(
                          word: state.isPaused ? " " : word,
                          hasMargins: !widget.position.isWordBank,
                        ),
                      ),
                    );
            },
          );
        },
      );
    });
  }

  Widget _buildEmptyCard(BuildContext context, int index) {
    return EmptyCard(
      color: _aboutToAcceptDrop
          ? Style.backgroundColorLight
          : Style.foregroundColorLight,
      outlineColor: Style.backgroundColorLight,
    );
  }
}

class CardDropData {
  final Size size;
  final GridPosition position;

  const CardDropData({required this.size, required this.position});
}
