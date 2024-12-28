import 'package:flutter/material.dart';
import 'package:phrazy/utility/style.dart';
import '../state.dart';
import '../utility/ext.dart';
import 'package:provider/provider.dart';

class PuzzleTimer extends StatelessWidget {
  const PuzzleTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(builder: (context, gameState, child) {
      return StreamBuilder<int>(
        stream: gameState.timer.secondTime,
        initialData: 0,
        builder: (context, snap) {
          final value = snap.data ?? 0;
          _recordTimeIfCurrentRoute(gameState, context);

          return Text(
            value.toDisplayTimeFromSeconds,
            style: Style.titleSmall,
          );
        },
      );
    });
  }

  void _recordTimeIfCurrentRoute(GameState gameState, BuildContext context) {
    if (gameState.isPreparing || gameState.isSolved) return;

    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    final timer = gameState.timer;

    if (!isCurrent) {
      timer.onStopTimer();
      return;
    }

    timer.onStartTimer();
    gameState.recordTime();
  }
}
