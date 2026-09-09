/// ThemeData factory: Light/Dark × accent seed (§14–§15).
library;

import 'package:flutter/material.dart';

import 'app_tokens.dart';

ThemeData buildLightTheme(Color seed) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
  return _build(scheme, AppTokens.light());
}

ThemeData buildDarkTheme(Color seed) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
  return _build(scheme, AppTokens.dark());
}

ThemeData _build(ColorScheme scheme, AppTokens tokens) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    cardTheme: CardThemeData(
      color: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokens.border),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: tokens.textPrimary,
      elevation: 0,
    ),
    dividerColor: tokens.border,
    extensions: [tokens],
  );
}
