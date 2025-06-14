import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phrazy/data/web_storage/web_storage.dart';
import 'package:phrazy/game_widgets/widget_lobbybox.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../utility/copy.dart';
import 'package:provider/provider.dart';

import '../state/state.dart';
import '../utility/ext.dart';
import '../utility/style.dart';

class SolvedCelebrationSection extends StatelessWidget {
  const SolvedCelebrationSection({super.key});

  void _copyResults(BuildContext context, GameState value) {
    final time = value.time;
    final text = Copy.shareString(value.loadedDate, time.toDisplayTime, time);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Widget _buildCelebrationText(BuildContext context, GameState value) {
    return Text(
      Copy.summaryString(value.loadedDate, value.time.toDisplayTime),
      style: Style.bodyMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        if (state.currentState != GameLifecycleState.solved) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Copy.congratsIcon(state.time), color: Style.yesColor),
                const SizedBox(width: 8),
                TextAnimator(Copy.congratsString(state.time),
                    style: Style.displayMedium),
              ],
            ),
            const SizedBox(height: 4),
            _buildCelebrationText(context, state),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _copyResults(context, state);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Style.yesColor,
                    foregroundColor: Style.textColor,
                  ),
                  child: const Text('Copy Results'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 16),
            if (WebStorage.isDeveloperMode) const LobbyBox(),
          ],
        );
      },
    );
  }
}
