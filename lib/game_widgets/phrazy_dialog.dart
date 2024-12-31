import 'package:flutter/material.dart';
import '../utility/style.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(4),
      backgroundColor: Style.textColor,
      elevation: 0,
      child: SizedBox(
        width: 540,
        child: SelectionArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Style.titleMedium),
                  const SizedBox(height: 16),
                  ...children,
                  if (buttons.isNotEmpty) const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(buttons.length, (index) {
                        final button = buttons[index];
                        return TextButton(
                          onPressed: button.onPressed,
                          style: TextButton.styleFrom(
                            backgroundColor: button.color ??
                                (index == buttons.length - 1
                                    ? Style.yesColor
                                    : Style.cardColor),
                            foregroundColor: Style.textColor,
                          ),
                          child: Text(button.text),
                        );
                      }),
                    ),
                  ),
                ],
              ),
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
