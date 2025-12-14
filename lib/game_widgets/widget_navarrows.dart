import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/core/ext_ymd.dart';
import 'package:phrazy/game/game_controller.dart';
import 'package:provider/provider.dart';

class NavigationArrows extends StatelessWidget {
  const NavigationArrows({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, state, child) {
        if (state.isPreparing) return const SizedBox.shrink();

        final loadedDate = state.loadedDate;

        if (loadedDate.isBefore(DateTime.fromMillisecondsSinceEpoch(1))) {
          return const SizedBox.shrink();
        }

        final previousDate = state.previousAvailableDate;
        final nextDate = state.nextAvailableDate;

        final bool canGoBack = previousDate != null;
        final bool canGoForward = nextDate != null;

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
                    message: "Previous available Phrazy",
                    child: IconButton(
                      icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
                      onPressed: () {
                        context.pushReplacement('/games/${previousDate.toYMD}');
                      },
                    ),
                  )
                else
                  const SizedBox(width: 48),
                if (canGoForward)
                  Tooltip(
                    message: "Next available Phrazy",
                    child: IconButton(
                      icon: const Icon(HugeIcons.strokeRoundedArrowRight01),
                      onPressed: () {
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
