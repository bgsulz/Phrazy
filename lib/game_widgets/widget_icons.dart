import 'package:flavor_text/flavor_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/utility/copy.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../game/game_controller.dart';
import '../utility/theme_notifier.dart';
import 'phrazy_dialog.dart';
import 'settings_dialog.dart';

class PhrazyIcons extends StatelessWidget {
  const PhrazyIcons({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.secondaryContainer;

    return WidgetAnimator(
      key: ValueKey(backgroundColor),
      incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(
        curve: Curves.easeOutCirc,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SettingsIcon(),
              Tooltip(
                message: 'Archive',
                child: IconButton(
                  icon: const Icon(HugeIcons.strokeRoundedArchive),
                  onPressed: () => context.pushReplacement('/games'),
                ),
              ),
              const ClearIcon(),
              const PauseIcon(),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsIcon extends StatefulWidget {
  const SettingsIcon({super.key});

  @override
  State<SettingsIcon> createState() => _SettingsIconState();
}

class _SettingsIconState extends State<SettingsIcon> {
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<PhrazyThemeNotifier>(
          builder: (context, themeNotifier, child) {
            return SettingsDialog(
              onAboutPressed: () {
                Navigator.of(context).pop(); // Close settings dialog
                _showInfo(context);
              },
            );
          },
        );
      },
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return PhrazyDialog(title: "Credits", buttons: [
          ButtonData(
            text: "Back to game",
            onPressed: () => context.pop(),
          ),
          ButtonData(
            text: "More of my work",
            onPressed: () => _launchUrl(
              Uri.parse("https://bgsulz.com"),
            ),
          ),
        ], children: [
          FlavorText(Copy.info),
        ]);
      },
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Settings',
      child: IconButton(
        icon: const Icon(HugeIcons.strokeRoundedSettings01),
        onPressed: () => _showSettingsDialog(context),
      ),
    );
  }
}

class ClearIcon extends StatelessWidget {
  const ClearIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, value, child) {
        if (!value.isPreparing && !value.isSolved) {
          return Tooltip(
            message: 'Clear',
            child: IconButton(
              icon: const Icon(HugeIcons.strokeRoundedEraser),
              onPressed: () {
                value.clearBoard();
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class PauseIcon extends StatelessWidget {
  const PauseIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, value, child) {
        if (!value.isPreparing && !value.isSolved) {
          return Tooltip(
            message: 'Pause',
            child: IconButton(
              icon: const Icon(HugeIcons.strokeRoundedPause),
              onPressed: () {
                _showPause(context);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showPause(BuildContext context) {
    final gameState = Provider.of<GameController>(context, listen: false);
    gameState.togglePause(true);

    showDialog(
      context: context,
      builder: (context) {
        return PhrazyDialog(
          title: 'Paused...',
          buttons: [
            ButtonData(
              text: 'Resume',
              onPressed: () {
                gameState.togglePause(false);
                Navigator.of(context).pop();
              },
            )
          ],
          children: const [
            Text('Game is paused.'),
          ],
        );
      },
    );
  }
}
