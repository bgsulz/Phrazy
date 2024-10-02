import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class GuesserScreen extends StatelessWidget {
  const GuesserScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _gradientBackground(context),
        // if (context.mounted)
        //   SelectionArea(child: _buildScaffold())
        // else
        _buildScaffold()
      ],
    );
  }

  Scaffold _buildScaffold() {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ))));
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
