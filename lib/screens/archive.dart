import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/load.dart';
import '../screens/hover.dart';
import '../state.dart';
import 'package:provider/provider.dart';
import '../utility/ext.dart';

class Archive extends StatelessWidget {
  const Archive({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcons(context),
        const SizedBox(height: 8),
        const Flexible(child: PuzzlesList()),
      ],
    );
  }

  Container _buildIcons(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go("/");
              }
            },
          )
        ]));
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      controller: _controller,
      itemCount: Load.totalDailies,
      itemBuilder: (context, index) {
        return Consumer<GameState>(
          builder: (BuildContext context, GameState gameState, Widget? child) {
            return PuzzleCard(date: Load.startDate.add(Duration(days: index)));
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        child: TranslateOnHover(
          isActive: true,
          child: Material(
            elevation: 4,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4))),
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: InkWell(
              onTap: () {
                context.go('/games/${date.toYMD}');
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      date.toDisplayDate,
                      maxLines: null,
                      textAlign: TextAlign.left,
                    ),
                    const Spacer(),
                    Text(
                      context.mounted
                          ? Load.loadTimeForDate(date.toYMD)?.toString() ?? ""
                          : "",
                      maxLines: null,
                      textAlign: TextAlign.right,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
