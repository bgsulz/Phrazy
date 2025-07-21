import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/core/ext_ymd.dart';
import 'package:phrazy/game_widgets/phrazy_dialog.dart';
import 'package:phrazy/utility/copy.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../data/web_storage/web_storage.dart';
import '../game_widgets/phrazy_box.dart';
import '../utility/style.dart';
import '../data/load.dart';
import '../utility/hover.dart';
import '../game/state.dart';
import 'package:provider/provider.dart';
import '../utility/ext.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final loadedDate = gameState.loadedPuzzle.isEmpty
        ? DateTime.now().copyWith(hour: 12)
        : gameState.loadedDate;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcons(context),
        const SizedBox(height: 8),
        Flexible(
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(16),
            child: PuzzlesList(loadedDate: loadedDate),
          ),
        ),
      ],
    );
  }

  Container _buildIcons(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
            onPressed: () {
              final state = Provider.of<GameState>(context, listen: false);
              if (state.loadedPuzzle.isEmpty) {
                context.pushReplacement('/');
              } else {
                context.pushReplacement('/games/${state.loadedDate.toYMD}');
              }
            },
          ),
          IconButton(
            icon: const Icon(
              HugeIcons.strokeRoundedTestTube01,
              color: Style.foregroundColor,
            ),
            onPressed: () {
              _openDevModeWindow(context);
            },
          )
        ],
      ),
    );
  }

  void _openDevModeWindow(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PhrazyDialog(
          title: 'Experimental Features!',
          buttons: <ButtonData>[
            ButtonData(
                text:
                    "Turn experimental features ${WebStorage.isDeveloperMode ? "off" : "on"}",
                onPressed: () {
                  context.pop();
                  WebStorage.toggleDeveloperMode();
                })
          ],
          children: [
            const Text(
              'Get a preview of upcoming features!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'These are under development and may be unstable.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              title: 'Lobbies',
              description:
                  'Submit your score to a lobby for you and your friends.\nAll the information you enter is encoded and completely anonymous!',
            ),
            _buildFeatureItem(
              title: 'Stats',
              description:
                  'See how your solve times stack up against other players.',
            ),
          ],
        );
      },
    );
  }

  static Widget _buildFeatureItem({
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class PuzzlesList extends StatefulWidget {
  const PuzzlesList({
    super.key,
    required this.loadedDate,
  });

  final DateTime loadedDate;

  @override
  State<PuzzlesList> createState() => _PuzzlesListState();
}

class _PuzzlesListState extends State<PuzzlesList> {
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    final loadedDate = widget.loadedDate;
    final totalDailies = Load.totalDailies;
    final endDate = Load.endDate;

    final initialScrollIndex = -loadedDate.difference(endDate).inDays - 4;
    final clampedInitialScrollIndex =
        initialScrollIndex.clamp(0, totalDailies - 1);

    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      initialScrollIndex: clampedInitialScrollIndex,
      itemCount: Load.totalDailies,
      reverse: true,
      itemBuilder: (context, index) {
        final date = Load.endDate.subtract(Duration(days: index));
        return PuzzleCard(
          date: date,
          isLoaded: date.isSameDayAs(widget.loadedDate),
        );
      },
    );
  }
}

class PuzzleCard extends StatelessWidget {
  const PuzzleCard({
    super.key,
    required this.date,
    required this.isLoaded,
  });

  final DateTime date;
  final bool isLoaded;

  @override
  Widget build(BuildContext context) {
    var loadedTime = WebStorage.loadTimeForDate(date.toYMD);
    var displayTime = context.mounted ? loadedTime?.toString() ?? "" : "";

    var isStarted = loadedTime != null;
    var isSolved = isStarted && !loadedTime.toString().endsWith('+');
    var color = isSolved
        ? Style.yesColor
        : isStarted
            ? Colors.amber
            : Style.cardColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        child: TranslateOnHover(
          isActive: true,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: PhrazyBox(
              color: color,
              outlineColor: isLoaded ? Style.cardColor : Style.textColor,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.black.withOpacity(0.1),
                  onTap: () {
                    context.pushReplacement('/games/${date.toYMD}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (date.weekday == 7)
                          const Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedEvil,
                                color: Style.textColor,
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        Text(
                          date.toDisplayDateWithDay,
                          maxLines: null,
                          textAlign: TextAlign.left,
                          style: const TextStyle(color: Style.textColor),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            if (isSolved)
                              Icon(
                                Copy.congratsIcon(loadedTime.time),
                                color: Style.textColor,
                                size: 16,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              displayTime,
                              maxLines: null,
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Style.textColor),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
