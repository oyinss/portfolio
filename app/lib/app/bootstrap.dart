library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api/auth_service.dart';
import '../core/api/portfolio_repository.dart';
import '../core/theme/accent_theme.dart';
import '../core/theme/theme_controller.dart';

ThemeMode _parseBrightness(String? raw) => switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

Future<({ThemeController theme, AuthService auth})> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final results = await Future.wait([ThemeController.load(), AuthService.load()]);
  final theme = results[0] as ThemeController;
  // Owner defaults (§16): apply when the visitor never chose a preference.
  // Short timeout so a dead API never stalls startup.
  try {
    final settings = await PortfolioRepository()
        .settings()
        .timeout(const Duration(seconds: 4));
    if (settings.isNotEmpty) {
      theme.applyOwnerDefaults(
        mode: _parseBrightness(settings['default_brightness']),
        accent: settings['default_theme'] != null
            ? AccentThemeX.fromKey(settings['default_theme'])
            : null,
      );
    }
  } catch (_) {
    // Offline / mock mode: keep built-in defaults.
  }
  return (theme: theme, auth: results[1] as AuthService);
}
