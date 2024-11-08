import 'package:flutter/material.dart';
import 'package:phrazy/utility/style.dart';

class PhrazyDialog extends StatelessWidget {
  const PhrazyDialog({
    super.key,
    required this.title,
    required this.children,
    required this.buttons,
  });

  final String title;
  final List<Widget> children;
  final List<ButtonData> buttons;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      child: SizedBox(
        width: 540,
        child: SelectionArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ...children,
                if (buttons.isNotEmpty) const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: buttons
                        .map((e) => TextButton(
                              onPressed: e.onPressed,
                              style: TextButton.styleFrom(
                                backgroundColor: e.color ?? Style.yesColor,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                              child: Text(e.text),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonData {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  ButtonData({
    required this.text,
    required this.onPressed,
    this.color,
  });
}
