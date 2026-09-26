import 'package:flutter/material.dart';

/// Puduu tokens v5 — "Ledger": warm paper journal, ink serif headlines,
/// ONE accent (ember). No pastel tiles, no toy pills, no generic blue.
/// Display: Fraunces (bundled). UI: Inter (bundled).
class PuduuColors {
  static const paper = Color(0xFFF6F3EC);
  static const paperDeep = Color(0xFFEFE8D8);
  static const card = Color(0xFFFFFDF8);
  static const ink = Color(0xFF1C1917);
  static const inkSoft = Color(0xFF44403C);
  static const mute = Color(0xFF78716C);
  static const faint = Color(0xFF6F655C);
  static const line = Color(0xFFE3DAC7);
  static const ember = Color(0xFF9A3412);
  static const emberDeep = Color(0xFF7C2D12);
  static const emberWash = Color(0xFFF7E8D2);
  static const moss = Color(0xFF5B6B1F);
  static const danger = Color(0xFFB91C1C);
}

/// Editorial text styles. Fraunces = headlines/timer numerals only.
class PuduuType {
  static const display = TextStyle(
    fontFamily: 'Fraunces',
    fontWeight: FontWeight.w600,
    color: PuduuColors.ink,
    height: 1.12,
    letterSpacing: -0.3,
  );
  static const title = TextStyle(
    fontFamily: 'Fraunces',
    fontWeight: FontWeight.w600,
    color: PuduuColors.ink,
    height: 1.2,
  );
  static TextStyle eyebrow([Color color = PuduuColors.mute]) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: color,
      );
  static const body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.5,
    height: 1.55,
    color: PuduuColors.inkSoft,
  );
  static const strong = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: PuduuColors.ink,
    height: 1.4,
  );
  static const meta = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.5,
    color: PuduuColors.mute,
    height: 1.45,
  );
  static const tabular = TextStyle(
    fontFamily: 'Inter',
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

/// Icon system (M3 + HIG rules): ONE family per surface, filled = active,
/// outlined = inactive. Nav icons share round 24px geometry; content icons
/// share 2px-stroke Lucide metaphors. Color comes from context, never icon.
class PuduuIcons {
  // Nav: outlined (inactive) / filled (active) pairs.
  static const today = Icons.calendar_today_outlined;
  static const todayFill = Icons.calendar_today;
  static const focus = Icons.timer_outlined;
  static const focusFill = Icons.timer;
  static const reset = Icons.refresh_outlined;
  static const resetFill = Icons.refresh;
  static const grows = Icons.bar_chart_outlined;
  static const growsFill = Icons.bar_chart;
  static const yours = Icons.settings_outlined;
  static const yoursFill = Icons.settings;
  // Content: single 2px-stroke metaphor each, no mixing.
  static const sort = Icons.auto_awesome_outlined;
  static const check = Icons.check;
  static const play = Icons.play_arrow;
  static const pause = Icons.pause;
  static const chevron = Icons.chevron_right;
  static const bell = Icons.notifications_outlined;
  static const sound = Icons.volume_up_outlined;
  static const crown = Icons.workspace_premium_outlined;
  static const calendar = Icons.calendar_today_outlined;
  static const plus = Icons.add;
  static const arrow = Icons.arrow_forward;
  static const drop = Icons.water_drop_outlined;
  static const walk = Icons.directions_walk;
  static const mail = Icons.mail_outline;
}

ThemeData puduuTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: PuduuColors.ink,
    onPrimary: Color(0xFFFFFDF8),
    secondary: PuduuColors.ember,
    onSecondary: Colors.white,
    tertiary: PuduuColors.moss,
    onTertiary: Colors.white,
    error: PuduuColors.danger,
    onError: Colors.white,
    surface: PuduuColors.card,
    onSurface: PuduuColors.ink,
    surfaceContainerLow: PuduuColors.paperDeep,
    onSurfaceVariant: PuduuColors.inkSoft,
    outline: PuduuColors.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PuduuColors.paper,
    fontFamily: 'Inter',
    dividerTheme: const DividerThemeData(
      color: PuduuColors.line,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: PuduuColors.paper,
      foregroundColor: PuduuColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: PuduuColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: PuduuColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PuduuColors.ink,
        foregroundColor: const Color(0xFFFFFDF8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PuduuColors.emberDeep,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PuduuColors.card,
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: PuduuColors.faint,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PuduuColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PuduuColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: PuduuColors.ink, width: 1.4),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: PuduuColors.paper,
      indicatorColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
          color: sel ? PuduuColors.ink : PuduuColors.faint,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return IconThemeData(
          color: sel ? PuduuColors.ink : PuduuColors.faint,
          size: 23,
        );
      }),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: PuduuColors.paper,
      selectedIconTheme:
          IconThemeData(color: PuduuColors.ink, size: 22),
      unselectedIconTheme:
          IconThemeData(color: PuduuColors.faint, size: 22),
      selectedLabelTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: PuduuColors.ink,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: PuduuColors.mute,
      ),
    ),
  );
}
