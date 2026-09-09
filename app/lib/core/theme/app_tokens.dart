/// Reusable theme tokens (§15). No hard-coded colours in widgets — read
/// these via `Theme.of(context).extension<AppTokens>()!`.
library;

import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color sidebar;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;

  const AppTokens({
    required this.sidebar,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
  });

  factory AppTokens.light() => const AppTokens(
        sidebar: Color(0xFFF8FAFC),
        card: Color(0xFFFFFFFF),
        border: Color(0xFFE2E8F0),
        textPrimary: Color(0xFF0F172A),
        textSecondary: Color(0xFF64748B),
        success: Color(0xFF16A34A),
        warning: Color(0xFFD97706),
        error: Color(0xFFDC2626),
      );

  factory AppTokens.dark() => const AppTokens(
        sidebar: Color(0xFF0F172A),
        card: Color(0xFF1E293B),
        border: Color(0xFF334155),
        textPrimary: Color(0xFFF1F5F9),
        textSecondary: Color(0xFF94A3B8),
        success: Color(0xFF22C55E),
        warning: Color(0xFFF59E0B),
        error: Color(0xFFF87171),
      );

  @override
  AppTokens copyWith({
    Color? sidebar,
    Color? card,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? error,
  }) =>
      AppTokens(
        sidebar: sidebar ?? this.sidebar,
        card: card ?? this.card,
        border: border ?? this.border,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        error: error ?? this.error,
      );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      sidebar: lerpColor(sidebar, other.sidebar),
      card: lerpColor(card, other.card),
      border: lerpColor(border, other.border),
      textPrimary: lerpColor(textPrimary, other.textPrimary),
      textSecondary: lerpColor(textSecondary, other.textSecondary),
      success: lerpColor(success, other.success),
      warning: lerpColor(warning, other.warning),
      error: lerpColor(error, other.error),
    );
  }
}

extension TokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
