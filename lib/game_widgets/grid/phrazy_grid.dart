import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class PhrazyGrid extends StatelessWidget {
  const PhrazyGrid(
      {required this.itemCount,
      required this.columnCount,
      required this.itemHeight,
      required this.builder,
      super.key,
      this.responsiveHeight = true});

  final int itemCount;
  final int columnCount;
  final double itemHeight;
  final Widget Function(int) builder;
  final bool responsiveHeight;

  @override
  Widget build(BuildContext context) {
    final rows = (itemCount / columnCount).ceil();
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: rows *
            itemHeight *
            (responsiveHeight ? ((1 + (constraints.maxWidth / 600)) / 2) : 1),
        child: LayoutGrid(
          columnSizes: repeat(columnCount, [1.fr]),
          rowSizes: repeat(rows, [1.fr]),
          children: List.generate(
            itemCount,
            builder,
          ),
        ),
      );
    });
  }
}
