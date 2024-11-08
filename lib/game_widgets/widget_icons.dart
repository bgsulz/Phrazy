import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phrazy/data/web_storage.dart';
import 'package:phrazy/utility/copy.dart';
import '../game_widgets/demo.dart';
import '../state.dart';
import 'package:provider/provider.dart';
import 'phrazy_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class PhrazyIcons extends StatelessWidget {
  const PhrazyIcons({super.key});

  @override
  Widget build(BuildContext context) {
    if (WebStorage.isFirstTime) {
      Future.delayed(Duration.zero, () {
        if (context.mounted) _showHelp(context);
      });
    }

    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const MuteIcon(),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showInfo(context),
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => _showHelp(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/games'),
          ),
          const PauseIcon(),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return PhrazyDialog(title: "How to play", children: [
          const Text(Copy.rules1),
          const SizedBox(height: 16),
          const Demo(type: 1),
          const SizedBox(height: 16),
          const Text(Copy.rules2),
          const SizedBox(height: 16),
          const Demo(type: 2),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                context.pop();
              },
              child: const Text("Let's play!"),
            ),
          ),
        ]);
      },
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return PhrazyDialog(title: "Credits", children: [
          const Text(Copy.info),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _launchUrl(Uri.parse("https://bgsulz.com"));
                },
                child: const Text("More of my work"),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ]);
      },
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}

class PauseIcon extends StatelessWidget {
  const PauseIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, value, child) {
        if (!value.isSolved) {
          return IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () {
              _showPause(context);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showPause(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.togglePause(true);

    showDialogSuper(
      onDismissed: (e) {
        gameState.togglePause(false);
      },
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Paused"),
          actionsAlignment: MainAxisAlignment.end,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Copy.motivation),
              const SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Resume"),
            )
          ],
        );
      },
    );
  }
}

class MuteIcon extends StatefulWidget {
  const MuteIcon({super.key});

  @override
  State<MuteIcon> createState() => _MuteIconState();
}

class _MuteIconState extends State<MuteIcon> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: WebStorage.isMuted
          ? const Icon(Icons.volume_off)
          : const Icon(Icons.volume_up),
      onPressed: () {
        WebStorage.toggleMute();
        setState(() {});
      },
    );
  }
}
