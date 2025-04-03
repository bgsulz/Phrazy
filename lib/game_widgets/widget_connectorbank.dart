import 'package:flutter/material.dart';
import 'package:phrazy/game_widgets/phrazy_box.dart';
import 'package:phrazy/utility/style.dart';

class Connector extends StatelessWidget {
  final String text;
  final bool isCheckedOff;

  const Connector({
    super.key,
    required this.text,
    required this.isCheckedOff,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isCheckedOff ? Style.yesColor : Style.foregroundColorLight;
    final Color textColor = isCheckedOff ? Style.textColor : Style.textColor;

    return PhrazyBox(
      elevation: 0,
      outlineWidth: 2,
      outlineColor: isCheckedOff ? Style.yesColor : Style.foregroundColorLight,
      borderRadius: BorderRadius.circular(10),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Text(
          text,
          style: Style.bodySmall.copyWith(color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ConnectorBank extends StatelessWidget {
  final List<String> allConnectors;
  final List<String> activeConnectors;

  const ConnectorBank({
    super.key,
    required this.allConnectors,
    required this.activeConnectors,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> remainingActive = List.from(activeConnectors);

    return PhrazyBox(
      elevation: 0,
      color: Colors.transparent,
      outlineColor: Style.backgroundColorLight,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: allConnectors.map((connectorText) {
              bool isChecked = false;
              if (remainingActive.contains(connectorText)) {
                isChecked = true;
                remainingActive.remove(connectorText);
              }
              return Connector(
                text: connectorText,
                isCheckedOff: isChecked,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
