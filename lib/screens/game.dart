import 'package:flutter/material.dart';
import 'package:phrasewalk/game_widgets/appbar.dart';
import 'package:phrasewalk/game_widgets/solve.dart';
import 'package:phrasewalk/game_widgets/wordbank.dart';
import 'package:phrasewalk/state.dart';
import 'package:provider/provider.dart';

import '../utility/style.dart';

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
          builder: (context, value, child) => const GuesserWordbank(),
        ),
        const SizedBox(height: 16),
        Consumer<GameState>(
          builder: (context, value, child) => GuesserSolveGrid(
            columnCount: value.loadedPuzzle.columns,
            grid: value.loadedPuzzle.grid,
          ),
        ),
        const SizedBox(height: 16),
        // Align(alignment: Alignment.centerRight, child: PuzzleTimer()
        //     // child: Text((ModalRoute.of(context)?.isCurrent != true).toString()),
        //     ),
        const SizedBox(height: 16),
        Consumer<GameState>(builder: (context, value, child) {
          return value.isSolved
              ? Text(
                  "You did it!",
                  style: Theme.of(context).textTheme.titleMedium,
                )
              : const SizedBox.shrink();
        }),
      ],
    ),
  );
}
