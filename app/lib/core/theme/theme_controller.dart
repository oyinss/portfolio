/// Visitor theme preference (§16): mode + accent, persisted in-browser.
/// Owner defaults come from the API later (Phase 4) — this controller only
/// stores the *visitor override*.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'accent_theme.dart';

class ThemeController extends ChangeNotifier {
  static const _modeKey = 'pf_theme_mode';
  static const _accentKey = 'pf_accent';

  ThemeMode _mode;
  AccentTheme _accent;
  final SharedPreferences _prefs;

  ThemeController._(this._prefs, this._mode, this._accent);

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = switch (prefs.getString(_modeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return ThemeController._(prefs, mode, AccentThemeX.fromKey(prefs.getString(_accentKey)));
  }

  ThemeMode get mode => _mode;
  AccentTheme get accent => _accent;

  bool get hasStoredMode => _prefs.containsKey(_modeKey);
  bool get hasStoredAccent => _prefs.containsKey(_accentKey);

  /// Applies owner defaults (§16) when the visitor has no stored preference.
  void applyOwnerDefaults({ThemeMode? mode, AccentTheme? accent}) {
    var changed = false;
    if (!hasStoredMode && mode != null && mode != _mode) {
      _mode = mode;
      changed = true;
    }
    if (!hasStoredAccent && accent != null && accent != _accent) {
      _accent = accent;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    await _prefs.setString(
      _modeKey,
      switch (mode) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', ThemeMode.system => 'system' },
    );
    notifyListeners();
  }

  Future<void> setAccent(AccentTheme accent) async {
    _accent = accent;
    await _prefs.setString(_accentKey, accent.key);
    notifyListeners();
  }

  /// Quick Light ↔ Dark toggle used by the AppBar icon.
  Future<void> toggleLightDark() =>
      setMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({super.key, required ThemeController super.notifier, required super.child});

  static ThemeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeScope>()!.notifier!;
}
