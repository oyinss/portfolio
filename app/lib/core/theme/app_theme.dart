/// ThemeData factory: Light/Dark × accent seed (§14–§15).
library;

import 'package:flutter/material.dart';

import 'app_tokens.dart';

ThemeData buildLightTheme(Color seed) {
  final scheme = _withTrueAccent(
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    seed,
  );
  return _build(scheme, AppTokens.light());
}

ThemeData buildDarkTheme(Color seed) {
  final scheme = _withTrueAccent(
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    seed,
  );
  return _build(scheme, AppTokens.dark());
}

/// Single source of truth for the accent color: `fromSeed` mutes the seed
/// into a tonal palette, so pin `primary`/`onPrimary` back to the exact
/// theme color. Every widget reading `colorScheme.primary` — buttons, pills,
/// chips, indicators on every page — follows automatically.
ColorScheme _withTrueAccent(ColorScheme scheme, Color seed) {
  final onAccent =
      ThemeData.estimateBrightnessForColor(seed) == Brightness.dark ? Colors.white : Colors.black;
  return scheme.copyWith(primary: seed, onPrimary: onAccent);
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
