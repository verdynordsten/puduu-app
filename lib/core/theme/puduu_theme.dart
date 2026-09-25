import 'package:flutter/material.dart';

/// Puduu design tokens v2 (mirror of puduu-design/tokens/puduu.tokens.json).
/// Rule: zero emoji in UI. Icons are Lucide-style line icons (Material
/// equivalents picked to match Lucide glyphs 1:1).
class PuduuColors {
  static const primary = Color(0xFF2563EB);
  static const primaryDeep = Color(0xFF1D4ED8);
  static const onPrimary = Colors.white;
  static const secondary = Color(0xFF0E7490);
  static const secondarySoft = Color(0xFFE0F2F7);
  static const accent = Color(0xFFEA580C);
  static const accentDeep = Color(0xFFC2410C);
  static const accentSoft = Color(0xFFFFF1E7);
  static const background = Color(0xFFF6F8FC);
  static const foreground = Color(0xFF0F172A);
  static const slate = Color(0xFF475569);
  static const line = Color(0xFFE2E8F0);
  static const card = Colors.white;
  static const muted = Color(0xFFEFF4FF);
  static const success = Color(0xFF15803D);
  static const successSoft = Color(0xFFE7F6EC);
  static const danger = Color(0xFFDC2626);
  static const timelineHues = [
    Color(0xFF2563EB),
    Color(0xFF0E7490),
    Color(0xFFEA580C),
    Color(0xFF15803D),
    Color(0xFF9333EA),
    Color(0xFFE11D48),
  ];
}

/// Lucide-mapped icons (no emoji anywhere).
class PuduuIcons {
  static const today = Icons.wb_sunny_outlined; // sun
  static const focus = Icons.timer_outlined; // timer
  static const reset = Icons.ac_unit; // snowflake
  static const grows = Icons.emoji_events_outlined; // trophy
  static const yours = Icons.settings_outlined; // settings
  static const sort = Icons.auto_awesome_outlined; // sparkles
  static const check = Icons.check; // check
  static const checkCircle = Icons.check_circle_outline; // circle-check
  static const play = Icons.play_arrow; // play
  static const chevron = Icons.chevron_right; // chevron-right
  static const bell = Icons.notifications_outlined; // bell
  static const sound = Icons.volume_up_outlined; // volume-2
  static const text = Icons.text_fields_outlined; // text
  static const account = Icons.person_outline; // user
  static const logout = Icons.logout; // log-out
  static const crown = Icons.workspace_premium_outlined; // crown
  static const calendar = Icons.calendar_today_outlined; // calendar
  static const mail = Icons.mail_outline; // mail-open
  static const water = Icons.water_drop_outlined; // glass-water
  static const steps = Icons.directions_walk; // footprints
  static const bolt = Icons.bolt_outlined; // zap
  static const smile = Icons.sentiment_satisfied_outlined; // smile
  static const heart = Icons.favorite_outline; // heart
  static const star = Icons.star_outline; // star
}

ThemeData puduuTheme() {
  final scheme = const ColorScheme(
    brightness: Brightness.light,
    primary: PuduuColors.primary,
    onPrimary: PuduuColors.onPrimary,
    secondary: PuduuColors.secondary,
    onSecondary: Colors.white,
    tertiary: PuduuColors.accent,
    onTertiary: Colors.white,
    error: PuduuColors.danger,
    onError: Colors.white,
    surface: PuduuColors.card,
    onSurface: PuduuColors.foreground,
    surfaceContainerLow: PuduuColors.muted,
    onSurfaceVariant: PuduuColors.slate,
    outline: PuduuColors.line,
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
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: PuduuColors.line),
      ),
      elevation: 1,
      shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.05),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Nunito'),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: PuduuColors.muted,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: PuduuColors.slate),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PuduuColors.line, width: 1.5),
      ),
    ),
  );
}
