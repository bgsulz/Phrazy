import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phrazy/data/lobby.dart';
import 'package:phrazy/game_widgets/phrazy_dialog.dart';
import 'package:phrazy/game_widgets/widget_scoreboard.dart';
import 'package:phrazy/game/state.dart';
import 'package:phrazy/utility/debug.dart';
import 'package:phrazy/utility/ext.dart';
import 'package:phrazy/utility/style.dart';
import 'package:provider/provider.dart';
import 'phrazy_box.dart';

class StatsBox extends StatefulWidget {
  final StatsBlock statsBlock;
  const StatsBox({required this.statsBlock, super.key});

  @override
  State<StatsBox> createState() => _StatsBoxState();
}

class _StatsBoxState extends State<StatsBox> {
  bool _isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: PhrazyBox(
        color: Style.textColor,
        child: ExpansionTile(
          expansionAnimationStyle: _isCollapsed
              ? AnimationStyle(curve: Curves.easeInCirc)
              : AnimationStyle(curve: Curves.easeOutCirc),
          title: Text(
            'Statistics',
            style: Style.bodyMedium,
          ),
          initiallyExpanded: !_isCollapsed,
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isCollapsed = !expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: Text(widget.statsBlock.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LobbyBox extends StatefulWidget {
  const LobbyBox({super.key});

  @override
  State<LobbyBox> createState() => _LobbyBoxState();
}

class _LobbyBoxState extends State<LobbyBox> {
  String _lobbyCode = '';
  String _playerName = '';
  bool _isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: PhrazyBox(
        color: Style.textColor,
        child: ExpansionTile(
          expansionAnimationStyle: _isCollapsed
              ? AnimationStyle(curve: Curves.easeInCirc)
              : AnimationStyle(curve: Curves.easeOutCirc),
          title: Text(
            'Lobbies',
            style: Style.bodyMedium,
          ),
          initiallyExpanded: !_isCollapsed,
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isCollapsed = !expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: _lobbyCode.isNotEmpty ? 'Lobby name' : null,
                      hintText: 'Enter lobby name',
                      hintStyle: Style.bodyMedium,
                      labelStyle: Style.bodyMedium,
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
                      labelText: _playerName.isNotEmpty ? 'Your name' : null,
                      hintText: 'Enter your name',
                      hintStyle: Style.bodyMedium,
                      labelStyle: Style.bodyMedium,
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
                        onPressed: _lobbyCode.isEmpty || _playerName.isEmpty
                            ? null
                            : () {
                                _submitToLobby(context);
                              },
                        style: Style.button,
                        child: const Text('Submit to Lobby'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _lobbyCode.isEmpty
                            ? null
                            : () {
                                _viewLobby(context);
                              },
                        style: Style.button,
                        child: const Text('View Lobby'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitToLobby(BuildContext context) {
    _submitResultsToLobby(context, _lobbyCode, _playerName);
  }

  void _submitResultsToLobby(
      BuildContext context, String lobbyCode, String playerName) {
    _saveToLobbyAsync(context, lobbyCode, playerName);
  }

  void _viewLobby(BuildContext context) async {
    final state = Provider.of<GameState>(context, listen: false);
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
              _copyLobby(context, _lobbyCode, data);
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

  void _saveToLobbyAsync(
      BuildContext context, String lobbyCode, String playerName) async {
    final state = Provider.of<GameState>(context, listen: false);
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
              _copyLobby(context, lobbyCode, data);
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

  void _copyLobby(
      BuildContext context, String lobbyCode, Map<String, int>? data) {
    final state = Provider.of<GameState>(context, listen: false);
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
