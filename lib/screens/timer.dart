import 'package:flutter/material.dart';
import 'package:phrasewalk/state.dart';
import 'package:provider/provider.dart';

class PuzzleTimer extends StatelessWidget {
  const PuzzleTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(builder: (context, value, child) {
      return SizedBox.shrink();
      // return Text(value.timer.toString());
    });
  }
}
