import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF315BE8);
  static const Color primaryLight = Color(0xFF5C7CFA);
  static const Color primaryDark = Color(0xFF203FAF);
  static const Color accent = Color(0xFFE51D74);
  static const Color accentLight = Color(0xFFFFE5F0);

  static const Color background = Color(0xFFF5F7FB);
  static const Color backgroundSoft = Color(0xFFEEF2F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F7FB);
  static const Color surfaceElevated = Color(0xFFE8EDF6);
  static const Color cardBg = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF17223B);
  static const Color textSecondary = Color(0xFF4F5D75);
  static const Color textMuted = Color(0xFF7B879D);

  static const Color success = Color(0xFF169B62);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFE53955);
  static const Color info = Color(0xFF2F80ED);

  static const Color border = Color(0xFFDCE2EC);
  static const Color borderSubtle = Color(0xFFE9EDF4);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF315BE8), Color(0xFF5537C8), Color(0xFF7027B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE51D74), Color(0xFFFF6B5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary blue gradient used for hero surfaces and primary actions.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF315BE8), Color(0xFF5537C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cool ocean gradient used for informational surfaces.
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warm sunset gradient used for offers, promos and highlights.
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFE51D74)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Fresh gradient used for success / booking confirmations.
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Soft, layered elevation shadows used across cards and sheets.
///
/// Keeping them in one place avoids the "flat grey border" look and gives
/// every surface the same depth language.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 36,
      offset: Offset(0, 16),
    ),
  ];

  /// Coloured glow used behind primary brand surfaces.
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.28),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ];

  /// Neutral glow used when a card lifts on press.
  static const List<BoxShadow> lift = [
    BoxShadow(
      color: Color(0x1F0F172A),
      blurRadius: 26,
      offset: Offset(0, 12),
    ),
  ];
}
