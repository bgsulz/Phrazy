import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/core/ext_ymd.dart';
import 'package:phrazy/utility/copy.dart';
import '../data/web_storage/web_storage.dart';
import '../game_widgets/phrazy_box.dart';
import '../utility/style.dart';
import '../data/load.dart';
import '../utility/hover.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';
import '../utility/ext.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcons(context),
        const SizedBox(height: 8),
        Flexible(
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(16),
            child: const PuzzlesList(),
          ),
        ),
      ],
    );
  }

  Container _buildIcons(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
          )
        ],
      ),
    );
  }
}

class PuzzlesList extends StatefulWidget {
  const PuzzlesList({
    super.key,
  });

  @override
  State<PuzzlesList> createState() => _PuzzlesListState();
}

class _PuzzlesListState extends State<PuzzlesList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      cacheExtent: 0.0,
      shrinkWrap: true,
      controller: _controller,
      itemCount: Load.totalDailies,
      reverse: true,
      itemBuilder: (context, index) {
        return Consumer<GameState>(
          builder: (BuildContext context, GameState gameState, Widget? child) {
            final date = Load.endDate.subtract(Duration(days: index));
            return PuzzleCard(date: date);
          },
        );
      },
    );
  }
}

class PuzzleCard extends StatelessWidget {
  const PuzzleCard({
    super.key,
    required this.date,
  });

  final DateTime date;

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
