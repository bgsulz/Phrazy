import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phrazy/data/puzzle.dart';
import 'package:phrazy/utility/copy.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:confetti/confetti.dart';

import '../game_widgets/phrazy_dialog.dart';
import '../state.dart';
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

    return FutureBuilder(
      future: state.prepare(date: date, puzzle: puzzle),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SelectionArea(child: _buildPage(state, context));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildPage(GameState state, BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<GameState>(
                builder: (context, value, child) {
                  // Hack city
                  if (value.shouldCelebrateWin) {
                    Future.delayed(const Duration(milliseconds: 0), () {
                      if (context.mounted) _showCelebration(context, value);
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
              const TitleText(),
              const SizedBox(height: 16),
              const PhrazyIcons(),
              const SizedBox(height: 16),
              Consumer<GameState>(
                builder: (context, value, child) =>
                    PhrazyWordbank(bank: value.loadedPuzzle.words),
              ),
              const SizedBox(height: 16),
              Consumer<GameState>(
                builder: (context, value, child) => PhrazySolveGrid(
                  puzzle: value.loadedPuzzle,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<GameState>(
                builder: (context, value, child) {
                  return value.isSolved
                      ? _buildSolvedCelebration(state, context, value)
                      : const Align(
                          alignment: Alignment.centerRight,
                          child: PuzzleTimer(),
                        );
                },
              ),
            ],
          ),
        ),
        _confettiLayer(state),
      ],
    );
  }

  IgnorePointer _confettiLayer(GameState state) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Center(
          child: ConfettiWidget(
            numberOfParticles: 200,
            minBlastForce: 20,
            maxBlastForce: 100,
            blastDirectionality: BlastDirectionality.explosive,
            confettiController: state.confetti,
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
      ),
    );
  }

  Column _buildSolvedCelebration(
      GameState state, BuildContext context, GameState value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(Copy.congratsString(state.timer.rawTime.value),
            style: Style.displayMedium),
        const SizedBox(height: 4),
        _buildCelebrationText(context, value),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _copyResults(context, value);
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
  }

  Widget _buildCelebrationText(BuildContext context, GameState value) {
    return Text(
      Copy.summaryString(
          value.loadedDate, value.timer.rawTime.value.toDisplayTime),
      style: Style.bodyMedium,
    );
  }

  void _copyResults(BuildContext context, GameState value) {
    final text = Copy.shareString(
        value.loadedDate, value.timer.rawTime.value.toDisplayTime);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _showCelebration(BuildContext context, GameState state) {
    showDialog(
      context: context,
      builder: (context) {
        return PhrazyDialog(
          title: Copy.congratsString(state.timer.rawTime.value),
          buttons: [
            if (state.loadedDate.year < 1980)
              ButtonData(
                text: "Let's do today's!",
                onPressed: () {
                  context.pop();
                  context.go("/");
                },
              ),
            ButtonData(
              text: "Admire grid",
              onPressed: () {
                context.pop();
              },
            ),
            ButtonData(
              text: "Copy results",
              onPressed: () {
                _copyResults(context, state);
                context.pop();
              },
            ),
          ],
          children: [
            _buildCelebrationText(context, state),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.compose(
            Vector3(0, 10, 0), Quaternion.euler(0, 0, -0.11), Vector3.all(1.2)),
        child: const OverflowBox(
          maxHeight: double.infinity,
          child: FittedBox(
            child: Center(
              child: SelectionContainer.disabled(
                child: Text(
                  Copy.title,
                  style: TextStyle(
                    color: Style.textColor,
                    fontSize: 999,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -48,
                    fontVariations: [FontVariation.weight(800)],
                  ),
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
