import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:phrazy/utility/style.dart';

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

  Widget _gradientBackground(BuildContext context) {
    return Positioned.fill(
      child: AnimatedMeshGradient(
        colors: [
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.surfaceContainer,
          Theme.of(context).colorScheme.surfaceContainerLow,
          Theme.of(context).colorScheme.surfaceContainerLowest,
        ],
        options: AnimatedMeshGradientOptions(
            frequency: 0, speed: 1, grain: 0.5, amplitude: 100),
      ),
    );
  }
}
