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

class Game extends StatelessWidget {
  final DateTime? date;
  const Game({
    super.key,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<GameState>(context, listen: false).prepare(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SelectionArea(child: _buildPage(context));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

Widget _buildPage(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GuesserAppBar(),
        const SizedBox(height: 16),
        Text(Style.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(Style.subtitle, style: Theme.of(context).textTheme.titleSmall),
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
                      Text(
                        "Solved!",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You solved the Phrasewalk for ${value.loadedDate.toDisplayDate} '
                        'in ${value.timer.rawTime.value.toDisplayTime}.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _copyResults(value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Copied to clipboard')),
                            );
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

void _copyResults(GameState value) {
  final text = 'Phrasewalk ${value.loadedDate.toDisplayDate}\n'
      '${value.timer.rawTime.value.toDisplayTime}';
  Clipboard.setData(ClipboardData(text: text));
}
