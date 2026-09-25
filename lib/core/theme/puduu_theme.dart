import 'package:flutter/material.dart';

/// Puduu tokens v4 — Editorial Calm.
/// Display font (Fredoka) ONLY for greetings, timer digits, hero title.
/// Everything else is Nunito. Zero emoji, Lucide-mapped icons only.
class PuduuColors {
  static const paper = Color(0xFFFAFAF8);
  static const card = Colors.white;
  static const ink = Color(0xFF111827);
  static const slate = Color(0xFF4B5563);
  static const faint = Color(0xFF9AA1AD);
  static const line = Color(0xFFE6E4DE);
  static const primary = Color(0xFF2563EB);
  static const primaryDeep = Color(0xFF1E40AF);
  static const pale = Color(0xFFEDF2FF);
  static const heroA = Color(0xFF101828);
  static const heroB = Color(0xFF232F4B);
  static const teal = Color(0xFF0E7490);
  static const tealSoft = Color(0xFFE4F3F6);
  static const amber = Color(0xFFEA580C);
  static const amberSoft = Color(0xFFFFF3E8);
  static const green = Color(0xFF15803D);
  static const greenSoft = Color(0xFFEAF5EE);
  static const purple = Color(0xFF7C3AED);
  static const purpleSoft = Color(0xFFF2EAFB);
  static const danger = Color(0xFFDC2626);
  static const rails = [primary, teal, amber, green];
  static List<Color> get timelineHues => rails;
}

/// Lucide-mapped icons (no emoji anywhere).
class PuduuIcons {
  static const today = Icons.wb_sunny_outlined;
  static const focus = Icons.timer_outlined;
  static const reset = Icons.ac_unit;
  static const grows = Icons.emoji_events_outlined;
  static const yours = Icons.settings_outlined;
  static const sort = Icons.auto_awesome_outlined;
  static const check = Icons.check;
  static const checkCircle = Icons.check_circle_outline;
  static const play = Icons.play_arrow;
  static const playCircle = Icons.play_circle_outline;
  static const chevron = Icons.chevron_right;
  static const bell = Icons.notifications_outlined;
  static const sound = Icons.volume_up_outlined;
  static const account = Icons.person_outline;
  static const crown = Icons.workspace_premium_outlined;
  static const calendar = Icons.calendar_today_outlined;
  static const calendarCheck = Icons.event_available_outlined;
  static const mail = Icons.mail_outline;
  static const water = Icons.water_drop_outlined;
  static const steps = Icons.directions_walk;
  static const bolt = Icons.bolt_outlined;
  static const trend = Icons.trending_up_outlined;
  static const sunSoft = Icons.wb_sunny_outlined;
}

ThemeData puduuTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: PuduuColors.primary,
    onPrimary: Colors.white,
    secondary: PuduuColors.teal,
    onSecondary: Colors.white,
    tertiary: PuduuColors.amber,
    onTertiary: Colors.white,
    error: PuduuColors.danger,
    onError: Colors.white,
    surface: PuduuColors.card,
    onSurface: PuduuColors.ink,
    surfaceContainerLow: PuduuColors.pale,
    onSurfaceVariant: PuduuColors.slate,
    outline: PuduuColors.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PuduuColors.paper,
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: PuduuColors.paper,
      foregroundColor: PuduuColors.ink,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: PuduuColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: PuduuColors.line),
      ),
      elevation: 1,
      shadowColor: const Color(0xFF111827).withValues(alpha: 0.05),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(48, 54),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Nunito'),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: sel ? PuduuColors.primary : PuduuColors.faint);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return IconThemeData(
            color: sel ? PuduuColors.primary : PuduuColors.faint, size: 24);
      }),
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
