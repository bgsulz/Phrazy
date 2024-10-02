import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phrasewalk/game_widgets/demo.dart';
import '../game_widgets/dialog.dart';
import 'package:phrasewalk/data/load.dart';
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
            icon: const Icon(Icons.help),
            onPressed: () => _showHelp(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/games');
            },
          ),
        ],
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // TextButton(
              //   onPressed: () {
              //     _launchUrl(Uri.parse("https://bgsulz.com"));
              //   },
              //   child: const Text("More of my work"),
              // ),
              // const SizedBox(width: 16),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  context.pop();
                },
                child: const Text("Let's play!"),
              ),
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
