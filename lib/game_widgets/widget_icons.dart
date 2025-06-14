import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flavor_text/flavor_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../data/web_storage/web_storage.dart';
import '../utility/copy.dart';
import '../utility/style.dart';
import '../game_widgets/demo.dart';
import '../state/state.dart';
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

    return WidgetAnimator(
      incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(
        curve: Curves.easeOutCirc,
      ),
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const MuteIcon(),
            Tooltip(
              message: 'Help',
              child: IconButton(
                icon: const Icon(HugeIcons.strokeRoundedHelpCircle),
                onPressed: () => _showHelp(context),
              ),
            ),
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
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return PhrazyDialog(title: "How to play", buttons: [
          ButtonData(
              text: "Try an easy one",
              onPressed: () {
                context.pop();
                context.pushReplacement('/demo');
              }),
          ButtonData(
              text: "About game",
              onPressed: () {
                context.pop();
                _showInfo(context);
              }),
          ButtonData(
              text: "Let's play!",
              onPressed: () {
                context.pop();
              })
        ], children: [
          FlavorText(Copy.rules1),
          const SizedBox(height: 16),
          const Demo(type: 1),
          const SizedBox(height: 16),
          FlavorText(Copy.rules2),
          const SizedBox(height: 16),
          const Demo(type: 2),
          const SizedBox(height: 16),
        ]);
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
            color: Style.cardColor,
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
}

class ClearIcon extends StatelessWidget {
  const ClearIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
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
    return Consumer<GameState>(
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
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.togglePause(true);

    showDialogSuper(
      onDismissed: (e) {
        gameState.togglePause(false);
      },
      context: context,
      builder: (context) {
        return PhrazyDialog(
          title: "Paused...",
          buttons: [
            ButtonData(
                text: "Resume",
                onPressed: () {
                  context.pop();
                })
          ],
          children: [
            Text(Copy.motivation),
            const SizedBox(height: 16),
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
    return Tooltip(
      message: WebStorage.isMuted ? 'Unmute' : 'Mute',
      child: IconButton(
        icon: WebStorage.isMuted
            ? const Icon(HugeIcons.strokeRoundedVolumeMute02)
            : const Icon(HugeIcons.strokeRoundedVolumeHigh),
        onPressed: () {
          WebStorage.toggleMute();
          setState(() {});
        },
      ),
    );
  }
}
