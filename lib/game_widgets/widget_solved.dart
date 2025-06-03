import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game_widgets/phrazy_box.dart';
import 'package:go_router/go_router.dart';
import 'package:phrazy/data/lobby.dart';
import 'package:phrazy/game_widgets/phrazy_dialog.dart';
import 'package:phrazy/game_widgets/widget_scoreboard.dart';
import 'package:phrazy/utility/debug.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../utility/copy.dart';
import 'package:provider/provider.dart';

import '../state/state.dart';
import '../utility/ext.dart';
import '../utility/style.dart';

class SolvedCelebrationSection extends StatefulWidget {
  const SolvedCelebrationSection({super.key});

  @override
  State<SolvedCelebrationSection> createState() =>
      _SolvedCelebrationSectionState();
}

class _SolvedCelebrationSectionState extends State<SolvedCelebrationSection> {
  String _lobbyCode = '';
  String _playerName = '';

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
            PhrazyBox(
              color: Style.textColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Lobby Code',
                        hintStyle: Style.bodyMedium,
                        border: const OutlineInputBorder(),
                      ),
                      style: Style.bodyMedium,
                      onChanged: (value) {
                        setState(() {
                          _lobbyCode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Your Name',
                        hintStyle: Style.bodyMedium,
                        border: const OutlineInputBorder(),
                      ),
                      style: Style.bodyMedium,
                      onChanged: (value) {
                        setState(() {
                          _playerName = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _submitToLobby(context, state);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Style.yesColor,
                            foregroundColor: Style.textColor,
                          ),
                          child: const Text('Submit to Lobby'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            _viewLobby(context, state);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Style.yesColor,
                            foregroundColor: Style.textColor,
                          ),
                          child: const Text('View Lobby'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitToLobby(BuildContext context, GameState state) {
    _submitResultsToLobby(context, state, _lobbyCode, _playerName);
  }

  void _submitResultsToLobby(BuildContext context, GameState state,
      String lobbyCode, String playerName) {
    _saveToLobbyAsync(context, state, lobbyCode, playerName);
  }

  void _viewLobby(BuildContext context, GameState state) async {
    final data =
        await Lobby.getScoreboard(_lobbyCode, state.loadedPuzzle.remoteId!);
    if (!context.mounted) {
      debug("context not mounted after getting scoreboard, early return");
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return PhrazyDialog(title: "Lobby $_lobbyCode", buttons: [
          ButtonData(
            text: "Copy lobby to clipboard",
            onPressed: () {
              _copyLobby(context, state, _lobbyCode, data);
              context.pop();
            },
          ),
          ButtonData(text: "Close", onPressed: context.pop),
        ], children: [
          ScoreboardDisplay(data)
        ]);
      },
    );
  }

  void _saveToLobbyAsync(BuildContext context, GameState state,
      String lobbyCode, String playerName) async {
    await Lobby.saveToLobby(state, lobbyCode, playerName);
    if (!context.mounted) {
      debug("context not mounted after saving lobby, early return");
      return;
    }
    final data =
        await Lobby.getScoreboard(lobbyCode, state.loadedPuzzle.remoteId!);
    if (!context.mounted) {
      debug("context not mounted after getting scoreboard, early return");
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return PhrazyDialog(title: "Submitted to lobby $lobbyCode!", buttons: [
          ButtonData(
            text: "Copy lobby to clipboard",
            onPressed: () {
              _copyLobby(context, state, lobbyCode, data);
              context.pop();
            },
          ),
          ButtonData(text: "Close", onPressed: context.pop),
        ], children: [
          ScoreboardDisplay(data)
        ]);
      },
    );
  }

  void _copyLobby(BuildContext context, GameState state, String lobbyCode,
      Map<String, int>? data) {
    final buffer = StringBuffer();
    if (data == null) return;

    final sorted = data.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    buffer
        .writeln('Phrazy ${state.loadedDate.toDisplayDate} - Lobby $lobbyCode');
    for (var entry in sorted) {
      buffer.writeln('${entry.key} - ${entry.value.toDisplayTime}');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied lobby to clipboard')),
    );
  }
}
