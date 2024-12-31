import 'package:flutter/material.dart';
import '../utility/style.dart';

class PhrazyScreen extends StatelessWidget {
  const PhrazyScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [_buildScaffold()],
    );
  }

  Scaffold _buildScaffold() {
    return Scaffold(
      backgroundColor: Style.backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
