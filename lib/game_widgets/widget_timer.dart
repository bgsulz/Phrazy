import 'package:flutter/material.dart';
import '../utility/style.dart';
import '../game/state.dart';
import '../utility/ext.dart';
import 'package:provider/provider.dart';

class SolveTimer extends StatelessWidget {
  const SolveTimer({super.key});

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
            style: Style.bodyMedium
                .copyWith(fontVariations: [const FontVariation("wght", 700)]),
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
