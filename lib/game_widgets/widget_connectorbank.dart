import 'package:flutter/material.dart';
import 'package:phrazy/game_widgets/phrazy_box.dart';
import 'package:phrazy/state/state.dart';
import 'package:phrazy/utility/style.dart';
import 'package:provider/provider.dart';

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
  final List<String>? allConnectorsOverride;
  final List<String>? activeConnectorsOverride;

  const ConnectorBank({
    super.key,
    this.allConnectorsOverride,
    this.activeConnectorsOverride,
  }) : assert(
            (allConnectorsOverride == null &&
                    activeConnectorsOverride == null) ||
                (allConnectorsOverride != null &&
                    activeConnectorsOverride != null),
            'Both allConnectorsOverride and activeConnectorsOverride must be provided together or not at all.');
  @override
  Widget build(BuildContext context) {
    return PhrazyBox(
      shouldAnimate: true,
      elevation: 0,
      color: Colors.transparent,
      outlineColor: Style.backgroundColorLight,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _ConnectorBankContent(
            allConnectorsOverride: allConnectorsOverride,
            activeConnectorsOverride: activeConnectorsOverride,
          ),
        ),
      ),
    );
  }
}

class _ConnectorBankContent extends StatelessWidget {
  final List<String>? allConnectorsOverride;
  final List<String>? activeConnectorsOverride;

  const _ConnectorBankContent({
    this.allConnectorsOverride,
    this.activeConnectorsOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, value, child) {
        final List<String> allConnectors =
            allConnectorsOverride ?? value.loadedPuzzle.connectors!;
        final List<String> activeConnectors =
            activeConnectorsOverride ?? value.activeConnections;
        final List<String> remainingActive = List.from(activeConnectors);

        return Wrap(
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
        );
      },
    );
  }
}
