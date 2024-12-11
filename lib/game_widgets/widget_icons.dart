import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phrazy/data/web_storage.dart';
import 'package:phrazy/utility/copy.dart';
import 'package:phrazy/utility/style.dart';
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
            icon: const Icon(HugeIcons.strokeRoundedHelpCircle),
            onPressed: () => _showHelp(context),
          ),
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedArchive),
            onPressed: () => context.go('/games'),
          ),
          const ClearIcon(),
          const PauseIcon(),
        ],
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
                context.go('/demo');
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
        ], children: const [
          Text(Copy.rules1),
          SizedBox(height: 16),
          Demo(type: 1),
          SizedBox(height: 16),
          Text(Copy.rules2),
          SizedBox(height: 16),
          Demo(type: 2),
          SizedBox(height: 16),
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
        ], children: const [
          Text(Copy.info),
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
        if (!value.isSolved) {
          return IconButton(
            icon: const Icon(HugeIcons.strokeRoundedEraser),
            onPressed: () {
              value.clearBoard();
            },
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
        if (!value.isSolved) {
          return IconButton(
            icon: const Icon(HugeIcons.strokeRoundedPause),
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
    return IconButton(
      icon: WebStorage.isMuted
          ? const Icon(HugeIcons.strokeRoundedVolumeMute02)
          : const Icon(HugeIcons.strokeRoundedVolumeHigh),
      onPressed: () {
        WebStorage.toggleMute();
        setState(() {});
      },
    );
  }
}
