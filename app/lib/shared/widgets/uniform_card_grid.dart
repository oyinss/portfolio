/// Grid whose cards size to content but stay equal height within each row.
/// Unlike fixed-extent tiles, rows with short content stay compact — and
/// unlike Wrap, cards in the same row always align.
library;

import 'package:flutter/material.dart';

class UniformCardGrid extends StatelessWidget {
  final int cols;
  final double gap;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  const UniformCardGrid({
    super.key,
    required this.cols,
    required this.itemCount,
    required this.itemBuilder,
    this.gap = 12,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<int>>[];
    for (var i = 0; i < itemCount; i += cols) {
      rows.add([for (var j = i; j < i + cols && j < itemCount; j++) j]);
    }
    return Column(
      children: [
        for (var r = 0; r < rows.length; r++)
          Padding(
            padding: EdgeInsets.only(bottom: r == rows.length - 1 ? 0 : gap),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var k = 0; k < rows[r].length; k++) ...[
                    if (k > 0) SizedBox(width: gap),
                    Expanded(child: itemBuilder(context, rows[r][k])),
                  ],
                  // Fill an incomplete last row so widths stay consistent.
                  for (var k = rows[r].length; k < cols; k++) ...[
                    SizedBox(width: gap),
                    const Expanded(child: SizedBox()),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
