import 'package:flutter/material.dart';

class TranslateOnHover extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const TranslateOnHover(
      {super.key, required this.child, this.isActive = true});

  @override
  State<TranslateOnHover> createState() => _TranslateOnHoverState();
}

class _TranslateOnHoverState extends State<TranslateOnHover> {
  final nonHoverTransform = Matrix4.identity()..translate(0, 0, 0);
  final hoverTransform = Matrix4.identity()..translate(0, -5, 0);
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _onMouseEvent(true),
      onExit: (e) => _onMouseEvent(false),
      child: widget.isActive
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              transform: _isHovering ? hoverTransform : nonHoverTransform,
              child: widget.child,
            )
          : widget.child,
    );
  }

  void _onMouseEvent(bool didEnter) {
    if (mounted) {
      setState(() {
        _isHovering = didEnter;
      });
    }
  }
}
