import 'package:phrazy/game_widgets/dialog.dart';

import '../state.dart';
import '../screens/timer.dart';
import '../game_widgets/appbar.dart';
import '../game_widgets/solve.dart';
import '../game_widgets/wordbank.dart';
import '../utility/ext.dart';
import '../utility/style.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart';

class Game extends StatelessWidget {
  final DateTime? date;
  const Game({
    super.key,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context, listen: false);

    return FutureBuilder(
      future: state.prepare(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SelectionArea(child: _buildPage(context));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    return SingleChildScrollView(
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
          const GuesserAppBar(),
          // const SizedBox(height: 8),
          // Text(Style.subtitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          Consumer<GameState>(
            builder: (context, value, child) =>
                GuesserWordbank(bank: value.loadedPuzzle.words),
          ),
          const SizedBox(height: 16),
          Consumer<GameState>(
            builder: (context, value, child) => GuesserSolveGrid(
              columnCount: value.loadedPuzzle.columns,
              grid: value.loadedPuzzle.grid,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<GameState>(
            builder: (context, value, child) {
              return value.isSolved
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text('Solved!',
                            style: Theme.of(context).textTheme.displayMedium),
                        const SizedBox(height: 16),
                        _buildCelebrationText(context, value),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _copyResults(context, value);
                            },
                            child: const Text('Copy Results'),
                          ),
                        ),
                      ],
                    )
                  : const Align(
                      alignment: Alignment.centerRight,
                      child: PuzzleTimer(),
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationText(BuildContext context, GameState value) {
    return Text(
      'You solved the ${Style.gameName} for ${value.loadedDate.toDisplayDate} '
      'in ${value.timer.rawTime.value.toDisplayTime}.',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  void _copyResults(BuildContext context, GameState value) {
    final text = '${Style.gameName} ${value.loadedDate.toDisplayDate}\n'
        '${value.timer.rawTime.value.toDisplayTime}\n'
        'https://phrazy.fun';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _showCelebration(BuildContext context, GameState state) {
    showDialog(
      context: context,
      builder: (context) {
        return GuesserDialog(
          title: "Solved!",
          children: [
            _buildCelebrationText(context, state),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _copyResults(context, state);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Copy results"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Resume"),
                )
              ],
            ),
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
            Vector3.zero(), Quaternion.euler(0, 0, -0.1), Vector3.all(1.2)),
        child: const OverflowBox(
          maxHeight: double.infinity,
          child: FittedBox(
            child: Center(
              child: SelectionContainer.disabled(
                child: Text(
                  Style.title,
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
