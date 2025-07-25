import 'package:flutter/material.dart';
import 'package:phrazy/game_widgets/phrazy_dialog.dart';
import 'package:phrazy/utility/settings_notifier.dart';
import 'package:phrazy/utility/theme_notifier.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatelessWidget {
  final VoidCallback onAboutPressed;

  const SettingsDialog({super.key, required this.onAboutPressed});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final theme = context.watch<PhrazyThemeNotifier>();

    return PhrazyDialog(
      shouldAnimate: false,
      title: 'Settings',
      buttons: [
        ButtonData(
          onPressed: () {
            onAboutPressed();
          },
          text: 'About this game',
        ),
      ],
      children: [
        SwitchListTile(
          title: const Text('Sound Effects'),
          value: !settings.isMuted,
          onChanged: (b) => settings.toggleMute(!b),
        ),
        SwitchListTile(
          title: const Text('High Contrast'),
          value: theme.isHighContrast,
          onChanged: theme.toggleTheme,
        ),
      ],
    );
  }
}
