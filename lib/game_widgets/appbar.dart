import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../game_widgets/demo.dart';
import '../state.dart';
import 'package:provider/provider.dart';
import '../game_widgets/dialog.dart';
import '../data/load.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utility/style.dart';

class GuesserAppBar extends StatelessWidget {
  const GuesserAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    if (Load.checkFirstTime()) {
      Future.delayed(Duration.zero, () {
        if (context.mounted) _showHelp(context);
      });
    }

    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
            onPressed: () {
              context.push('/games');
            },
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () {
              _showPause(context);
            },
          ),
        ],
      ),
    );
  }

  void _showPause(BuildContext context) {
    final appState = Provider.of<GameState>(context, listen: false);
    appState.togglePause(true);

    showDialogSuper(
      onDismissed: (e) {
        appState.togglePause(false);
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
              Text(
                [
                  "You're doing great!",
                  "Keep up the good work!",
                  "You've got this one!"
                ][Random().nextInt(3)],
              ),
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

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return GuesserDialog(title: "How to play", children: [
          const Text(Style.rules1),
          const SizedBox(height: 16),
          const Demo(type: 1),
          const SizedBox(height: 16),
          const Text(Style.rules2),
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
        return GuesserDialog(title: "Credits", children: [
          const Text(Style.info),
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
