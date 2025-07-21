import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phrazy/game_widgets/widget_overlayconfetti.dart';
import 'package:phrazy/game_widgets/widget_solved.dart';
import 'package:phrazy/game_widgets/widget_navarrows.dart';
import 'package:phrazy/game_widgets/widget_titletext.dart';
import '../data/puzzle.dart';
import '../game_widgets/widget_connectorbank.dart';
import '../utility/copy.dart';
import 'package:provider/provider.dart';

import '../game/state.dart';
import '../game_widgets/widget_timer.dart';
import '../game_widgets/widget_icons.dart';
import '../game_widgets/widget_solvegrid.dart';
import '../game_widgets/widget_wordbankgrid.dart';
import '../utility/style.dart';
import '../utility/ext.dart';

class GameScreen extends StatelessWidget {
  final Puzzle? puzzle;
  final DateTime? date;

  const GameScreen({super.key, this.date, this.puzzle});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context, listen: false);
    state.prepare(date: date, puzzle: puzzle);

    return const SelectionArea(
      child: _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatefulWidget {
  const _GameScreenContent();

  @override
  State<_GameScreenContent> createState() => _GameScreenContentState();
}

class _GameScreenContentState extends State<_GameScreenContent> {
  StreamSubscription<void>? _winSubscription;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<GameState>(context, listen: false);
    _winSubscription = state.onWin.listen((_) {
      state.confetti.play();
    });
  }

  @override
  void dispose() {
    _winSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context, listen: false);

    return Stack(
      alignment: Alignment.center,
      children: [
        const SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48),
                TitleText(),
                SizedBox(height: 16),
                PhrazyIcons(),
                _LoadingErrorIndicator(),
                _WordBankSection(),
                _ConnectorBankSection(),
                SizedBox(height: 16),
                _SolveGridSection(),
                SizedBox(height: 16),
                _BylineAndTimerRow(),
                NavigationArrows(),
                SolvedCelebrationSection(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
        ConfettiOverlay(controller: state.confetti),
      ],
    );
  }
}

class _LoadingErrorIndicator extends StatelessWidget {
  const _LoadingErrorIndicator();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        if (state.isPreparing) {
          return SizedBox(
            height: 460,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Copy.downloading),
                const SizedBox(height: 32),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        } else if (state.isError) {
          return const SizedBox(
            height: 460,
            child: Center(
              child: Text(
                "Something went wrong -- couldn't load the puzzle!",
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _WordBankSection extends StatelessWidget {
  const _WordBankSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        if (state.currentState == GameLifecycleState.puzzle) {
          return Column(
            children: [
              const SizedBox(height: 16),
              WordbankGrid(bank: state.loadedPuzzle.words),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ConnectorBankSection extends StatelessWidget {
  const _ConnectorBankSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        if (state.currentState == GameLifecycleState.puzzle &&
            state.loadedPuzzle.connectors != null) {
          return const Column(
            children: [
              SizedBox(height: 16),
              ConnectorBank(),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SolveGridSection extends StatelessWidget {
  const _SolveGridSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        if (state.currentState == GameLifecycleState.puzzle ||
            state.currentState == GameLifecycleState.solved) {
          return SolveGrid(
            puzzle: state.loadedPuzzle,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _BylineAndTimerRow extends StatelessWidget {
  const _BylineAndTimerRow();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        if (state.currentState == GameLifecycleState.error ||
            state.currentState == GameLifecycleState.preparing) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!state.isSolved)
              const Align(
                alignment: Alignment.centerLeft,
                child: SolveTimer(),
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  state.loadedDate.year < 1980
                      ? "Tutorial"
                      : state.loadedDate.toDisplayDateWithDay,
                  style: Style.bodyMedium,
                ),
                _buildByline(state),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildByline(GameState state) {
    if (state.loadedPuzzle.author case var author?) {
      return Text(
        "by $author",
        style: Style.titleSmall.copyWith(fontSize: 14),
      );
    }
    return const SizedBox.shrink();
  }
}
