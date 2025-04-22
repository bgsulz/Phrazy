import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/core/ext_ymd.dart';
import 'package:phrazy/data/load.dart';
import 'package:phrazy/state/state.dart';
import 'package:provider/provider.dart';

class NavigationArrows extends StatelessWidget {
  const NavigationArrows({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        final loadedDate = state.loadedDate;

        if (loadedDate.isBefore(DateTime.fromMillisecondsSinceEpoch(1))) {
          return const SizedBox.shrink();
        }

        final bool canGoBack = state.loadedDate.isAfter(Load.startDate);
        final bool canGoForward =
            state.loadedDate.isBefore(Load.endDate.copyWith(hour: 2));

        if (!canGoBack && !canGoForward) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (canGoBack)
                  Tooltip(
                    message: "Previous day's Phrazy",
                    child: IconButton(
                      icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
                      onPressed: () {
                        final prevDate = loadedDate
                            .subtract(const Duration(days: 1, hours: 2));
                        context.pushReplacement('/games/${prevDate.toYMD}');
                      },
                    ),
                  )
                else
                  const SizedBox(width: 48),
                if (canGoForward)
                  Tooltip(
                    message: "Next day's Phrazy",
                    child: IconButton(
                      icon: const Icon(HugeIcons.strokeRoundedArrowRight01),
                      onPressed: () {
                        final nextDate =
                            loadedDate.add(const Duration(days: 1, hours: 2));
                        context.pushReplacement('/games/${nextDate.toYMD}');
                      },
                    ),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ],
        );
      },
    );
  }
}
