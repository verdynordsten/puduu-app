import 'package:flutter/material.dart';

/// Puduu design tokens (mirror of puduu-design/tokens/puduu.tokens.json).
class PuduuColors {
  static const primary = Color(0xFF2563EB);
  static const onPrimary = Colors.white;
  static const secondary = Color(0xFF0891B2);
  static const onSecondary = Color(0xFF002430);
  static const accent = Color(0xFFEA580C);
  static const onAccent = Colors.white;
  static const background = Color(0xFFF8FAFC);
  static const foreground = Color(0xFF0F172A);
  static const card = Colors.white;
  static const muted = Color(0xFFF1F5FD);
  static const mutedFg = Color(0xFF475569);
  static const border = Color(0xFFE4ECFC);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
  static const timelineHues = [
    Color(0xFF2563EB),
    Color(0xFF0891B2),
    Color(0xFFEA580C),
    Color(0xFF16A34A),
    Color(0xFF9333EA),
    Color(0xFFE11D48),
  ];
}

ThemeData puduuTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.light,
    primary: PuduuColors.primary,
    onPrimary: PuduuColors.onPrimary,
    secondary: PuduuColors.secondary,
    onSecondary: PuduuColors.onSecondary,
    tertiary: PuduuColors.accent,
    onTertiary: PuduuColors.onAccent,
    error: PuduuColors.danger,
    onError: Colors.white,
    surface: PuduuColors.card,
    onSurface: PuduuColors.foreground,
    surfaceContainerLow: PuduuColors.muted,
    onSurfaceVariant: PuduuColors.mutedFg,
    outline: PuduuColors.border,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PuduuColors.background,
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: PuduuColors.background,
      foregroundColor: PuduuColors.foreground,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: PuduuColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFF1F5FD)),
      ),
      elevation: 2,
      shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.06),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PuduuColors.border, width: 2),
      ),
    ),
  );
}
