/// Accent options (§14 of the plan: Blue / Purple / Emerald).
library;

import 'package:flutter/material.dart';

enum AccentTheme { blue, purple, emerald, red, orange, yellow, pink, cyan, lime, slate, brown, indigo }

extension AccentThemeX on AccentTheme {
  String get label => switch (this) {
        AccentTheme.blue => 'Blue',
        AccentTheme.purple => 'Purple',
        AccentTheme.emerald => 'Emerald',
        AccentTheme.red => 'Red',
        AccentTheme.orange => 'Orange',
        AccentTheme.yellow => 'Yellow',
        AccentTheme.pink => 'Pink',
        AccentTheme.cyan => 'Cyan',
        AccentTheme.lime => 'Lime',
        AccentTheme.slate => 'Slate',
        AccentTheme.brown => 'Brown',
        AccentTheme.indigo => 'Indigo',
      };

  /// Storage key (§16: visitor preference persisted locally).
  String get key => name;

  Color get seed => switch (this) {
        AccentTheme.blue => const Color(0xFF2563EB),
        AccentTheme.purple => const Color(0xFF7C3AED),
        AccentTheme.emerald => const Color(0xFF059669),
        AccentTheme.red => const Color(0xFFE11D48),
        AccentTheme.orange => const Color(0xFFF97316),
        AccentTheme.yellow => const Color(0xFFEAB308),
        AccentTheme.pink => const Color(0xFFEC4899),
        AccentTheme.cyan => const Color(0xFF06B6D4),
        AccentTheme.lime => const Color(0xFF84CC16),
        AccentTheme.slate => const Color(0xFF475569),
        AccentTheme.brown => const Color(0xFF795548),
        AccentTheme.indigo => const Color(0xFF3F51B1),
      };

  static AccentTheme fromKey(String? key) => AccentTheme.values.firstWhere(
        (a) => a.key == key,
        orElse: () => AccentTheme.blue,
      );
}
