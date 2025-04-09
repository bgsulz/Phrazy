import 'package:flutter/material.dart';
import '../utility/style.dart';

class PhrazyDialog extends StatefulWidget {
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
  State<PhrazyDialog> createState() => _PhrazyDialogState();
}

class _PhrazyDialogState extends State<PhrazyDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
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
                    Text(widget.title, style: Style.titleMedium),
                    const SizedBox(height: 16),
                    ...widget.children,
                    if (widget.buttons.isNotEmpty) const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 16,
                        runSpacing: 16,
                        children: List.generate(widget.buttons.length, (index) {
                          final button = widget.buttons[index];
                          return TextButton(
                            onPressed: button.onPressed,
                            style: TextButton.styleFrom(
                              backgroundColor: button.color ??
                                  (index == widget.buttons.length - 1
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
