library;

import 'package:flutter/material.dart';

class TechChip extends StatelessWidget {
  final String label;
  const TechChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: scheme.primary.withValues(alpha: 0.1),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
