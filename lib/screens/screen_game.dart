import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phrazy/game_widgets/widget_navarrows.dart';
import 'package:phrazy/game_widgets/widget_titletext.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../data/puzzle.dart';
import '../game_widgets/widget_connectorbank.dart';
import '../utility/copy.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import '../state/state.dart';
import '../game_widgets/widget_timer.dart';
import '../game_widgets/widget_icons.dart';
import '../game_widgets/widget_solvegrid.dart';
import '../game_widgets/widget_wordbankgrid.dart';
import '../utility/ext.dart';
import '../utility/style.dart';

class GameScreen extends StatelessWidget {
  final Puzzle? puzzle;
  final DateTime? date;

  const GameScreen({super.key, this.date, this.puzzle});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context, listen: false);
    state.prepare(date: date, puzzle: puzzle);

    return SelectionArea(
      child: _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context, listen: false);

    _conditionallyShowCelebrationDialog(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        const SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                _SolvedCelebrationSection(),
                NavigationArrows(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _ConfettiOverlay(controller: state.confetti),
      ],
    );
  }

  void _conditionallyShowCelebrationDialog(BuildContext context) {
    final state = Provider.of<GameState>(context);
    if (state.shouldCelebrateWin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && state.shouldCelebrateWin) {
          state.acknowledgeWinCelebration();
        }
      });
    }
  }

  void _copyResults(BuildContext context, GameState value) {
    final text = Copy.shareString(
        value.loadedDate, value.timer.rawTime.value.toDisplayTime);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Widget _buildCelebrationText(BuildContext context, GameState value) {
    return Text(
      Copy.summaryString(
          value.loadedDate, value.timer.rawTime.value.toDisplayTime),
      style: Style.bodyMedium,
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
        if (state.currentState == GameLifecycleState.puzzle) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: _buildByline(state),
              ),
              const SizedBox(width: 8),
              if (!state.isSolved)
                const Align(
                  alignment: Alignment.centerRight,
                  child: SolveTimer(),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildByline(GameState state) {
    if (state.loadedPuzzle.author case var author?) {
      return Text("Puzzle by $author", style: Style.titleSmall);
    }
    return const SizedBox.shrink();
  }
}

class _SolvedCelebrationSection extends StatelessWidget {
  const _SolvedCelebrationSection();

  void _copyResults(BuildContext context, GameState value) {
    final text = Copy.shareString(
        value.loadedDate, value.timer.rawTime.value.toDisplayTime);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Widget _buildCelebrationText(BuildContext context, GameState value) {
    return Text(
      Copy.summaryString(
          value.loadedDate, value.timer.rawTime.value.toDisplayTime),
      style: Style.bodyMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        if (state.currentState != GameLifecycleState.solved) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Copy.congratsIcon(state.timer.rawTime.value),
                    color: Style.yesColor),
                const SizedBox(width: 8),
                TextAnimator(Copy.congratsString(state.timer.rawTime.value),
                    style: Style.displayMedium),
              ],
            ),
            const SizedBox(height: 4),
            _buildCelebrationText(context, state),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _copyResults(context, state);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Style.yesColor,
                  foregroundColor: Style.textColor,
                ),
                child: const Text('Copy Results'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConfettiOverlay extends StatelessWidget {
  final ConfettiController controller;

  const _ConfettiOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: ConfettiWidget(
          numberOfParticles: 800,
          minBlastForce: 40,
          maxBlastForce: 150,
          blastDirectionality: BlastDirectionality.explosive,
          confettiController: controller,
          colors: const [
            Style.yesColor,
            Style.noColor,
            Style.cardColor,
            Style.backgroundColor,
            Style.textColor,
            Style.backgroundColorLight,
          ],
        ),
      ),
    );
  }
}
