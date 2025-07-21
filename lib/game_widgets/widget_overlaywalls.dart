import 'package:flutter/material.dart';
import '../utility/style.dart';
import '../data/puzzle.dart';

class OverlayWallGrid extends StatelessWidget {
  const OverlayWallGrid({
    required this.data,
    super.key,
  });

  final TileData data;

  @override
  Widget build(BuildContext context) {
    const highlightColor = Style.textColor;

    // For filled cells, use a simple colored container
    if (data == TileData.filled) {
      return IgnorePointer(
        child: Container(
          color: highlightColor,
        ),
      );
    }

    // For walls, use custom painter
    return IgnorePointer(
      child: CustomPaint(
        painter: WallPainter(
          isRight: data == TileData.wallRight || data == TileData.wallBoth,
          isDown: data == TileData.wallDown || data == TileData.wallBoth,
          wallColor: highlightColor,
          wallWidth: 6.0,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class WallPainter extends CustomPainter {
  WallPainter({
    required this.isRight,
    required this.isDown,
    required this.wallColor,
    required this.wallWidth,
  });

  final bool isRight;
  final bool isDown;
  final Color wallColor;
  final double wallWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = wallColor
      ..strokeWidth = wallWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isRight) {
      final startPoint = Offset(size.width, 0);
      final endPoint = Offset(size.width, size.height);
      canvas.drawLine(startPoint, endPoint, paint);
    }

    if (isDown) {
      final startPoint = Offset(0, size.height);
      final endPoint = Offset(size.width, size.height);
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(WallPainter oldDelegate) {
    return oldDelegate.isRight != isRight ||
        oldDelegate.isDown != isDown ||
        oldDelegate.wallColor != wallColor ||
        oldDelegate.wallWidth != wallWidth;
  }
}
