import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/core/ext_ymd.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../data/load.dart';
import '../data/puzzle.dart';
import '../game_widgets/widget_connectorbank.dart';
import '../utility/copy.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:confetti/confetti.dart';

import '../game_widgets/phrazy_dialog.dart';
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
    return SelectionArea(child: _buildPage(state, context));
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
                  if (value.isPreparing) return const SizedBox.shrink();
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
              Consumer<GameState>(builder: (context, value, child) {
                if (!value.isPreparing) return const SizedBox.shrink();
                return SizedBox(
                  height: 460,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Copy.downloading),
                      const SizedBox(height: 32),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                );
              }),
              Consumer<GameState>(
                builder: (context, value, child) {
                  if (value.isPreparing || value.isSolved) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      WordbankGrid(bank: value.loadedPuzzle.words)
                    ],
                  );
                },
              ),
              Consumer<GameState>(
                builder: (context, value, child) {
                  if (value.isPreparing ||
                      value.isSolved ||
                      value.loadedPuzzle.connectors == null) {
                    return const SizedBox.shrink();
                  }
                  return const Column(
                    children: [SizedBox(height: 16), ConnectorBank()],
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<GameState>(
                builder: (context, value, child) {
                  if (value.isPreparing) return const SizedBox.shrink();
                  return SolveGrid(
                    puzzle: value.loadedPuzzle,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Consumer<GameState>(
                      builder: (context, value, child) {
                        return value.isPreparing
                            ? const SizedBox.shrink()
                            : _buildByline(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<GameState>(
                    builder: (context, value, child) {
                      return value.isPreparing || value.isSolved
                          ? const SizedBox.shrink()
                          : const Align(
                              alignment: Alignment.centerRight,
                              child: SolveTimer(),
                            );
                    },
                  ),
                ],
              ),
              Consumer<GameState>(builder: _buildSolvedCelebration),
              Consumer<GameState>(builder: _buildArrows),
            ],
          ),
        ),
        _confettiLayer(state),
      ],
    );
  }

  Widget _confettiLayer(GameState state) {
    if (!state.isPreparing) return const SizedBox.shrink();
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

  Widget _buildByline(GameState value) {
    if (value.loadedPuzzle.author case var author?) {
      return Text("Puzzle by $author", style: Style.titleSmall);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSolvedCelebration(
      BuildContext context, GameState state, Widget? widget) {
    if (state.isPreparing || !state.isSolved) return const SizedBox.shrink();

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
            Text(Copy.congratsString(state.timer.rawTime.value),
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
                  context.pushReplacement("/");
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

  Widget _buildArrows(BuildContext context, GameState value, Widget? child) {
    final loadedDate = value.loadedDate;

    if (loadedDate.isBefore(DateTime.fromMillisecondsSinceEpoch(1))) {
      return const SizedBox.shrink();
    }

    final isFirst = !value.loadedDate.isAfter(Load.startDate);
    final isLast = !value.loadedDate.isBefore(Load.endDate.copyWith(hour: 2));

    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isFirst)
              Tooltip(
                message: "Previous day's Phrazy",
                child: IconButton(
                  icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
                  onPressed: () {
                    context.pushReplacement(
                        '/games/${loadedDate.subtract(const Duration(days: 1, hours: 2)).toYMD}');
                  },
                ),
              ),
            const Spacer(),
            if (!isLast)
              Tooltip(
                message: "Next day's Phrazy",
                child: IconButton(
                  icon: const Icon(HugeIcons.strokeRoundedArrowRight01),
                  onPressed: () {
                    context.pushReplacement(
                        '/games/${loadedDate.add(const Duration(days: 1, hours: 2)).toYMD}');
                  },
                ),
              ),
          ],
        ),
      ],
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
        child: OverflowBox(
          maxHeight: double.infinity,
          child: FittedBox(
            child: Center(
              child: SelectionContainer.disabled(
                child: TextAnimator(
                  Copy.title,
                  incomingEffect:
                      WidgetTransitionEffects.incomingSlideInFromBottom(
                    curve: Curves.easeOutCirc,
                  ),
                  atRestEffect: WidgetRestingEffects.wave(
                    effectStrength: 10,
                    curve: Curves.easeInOutCirc,
                  ),
                  style: const TextStyle(
                    color: Style.textColor,
                    fontSize: 999,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -48,
                    fontVariations: [FontVariation.weight(800)],
                  ),
                  // overflow: TextOverflow.visible,
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
