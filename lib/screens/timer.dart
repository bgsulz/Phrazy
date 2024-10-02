import 'package:flutter/material.dart';
import 'package:phrasewalk/state.dart';
import 'package:phrasewalk/utility/ext.dart';
import 'package:provider/provider.dart';

class PuzzleTimer extends StatefulWidget {
  const PuzzleTimer({super.key});

  @override
  State<PuzzleTimer> createState() => _PuzzleTimerState();
}

class _PuzzleTimerState extends State<PuzzleTimer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(builder: (context, appState, child) {
      return StreamBuilder<int>(
        stream: appState.timer.secondTime,
        initialData: 0,
        builder: (context, snap) {
          final value = snap.data;
          _recordTimeIfCurrentRoute(appState, context);

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    value!.toDisplayTimeFromSeconds,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _recordTimeIfCurrentRoute(GameState appState, BuildContext context) {
    if (appState.isSolved) return;

    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    final timer = appState.timer;

    if (!isCurrent) {
      timer.onStopTimer();
      return;
    }

    timer.onStartTimer();
    appState.recordTime();
  }
}
