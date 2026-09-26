import 'package:flutter/material.dart';

/// Puduu tokens v10 — "Fresh Start" (DocSpot-class).
/// White cards, teal accent, dark ink, Outfit display + Work Sans UI.
/// Ledger DNA is dead: no paper/ember/serif anywhere.
class PuduuColors {
  static const bg = Color(0xFFF2F5F4);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F1F1E);
  static const soft = Color(0xFF3E5452);
  static const mute = Color(0xFF7A8F8D);
  static const line = Color(0xFFE4EBEA);
  static const teal = Color(0xFF0E9384);
  static const tealDeep = Color(0xFF0B7468);
  static const tealWash = Color(0xFFDDF3F0);
  static const amber = Color(0xFFF59E0B);
  static const amberWash = Color(0xFFFEF3DF);
  static const moss = Color(0xFF4D7C0F);
  static const mossWash = Color(0xFFEFF6DF);
  static const dark = Color(0xFF101E1D);
  static const danger = Color(0xFFDC2626);
}

class PuduuType {
  static const display = TextStyle(
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w700,
    color: PuduuColors.ink,
    height: 1.15,
    letterSpacing: -0.2,
  );
  static const title = TextStyle(
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w600,
    color: PuduuColors.ink,
    height: 1.25,
  );
  static TextStyle label([Color color = PuduuColors.soft]) => TextStyle(
        fontFamily: 'Outfit',
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: color,
      );
  static const body = TextStyle(
    fontFamily: 'Work Sans',
    fontSize: 13.5,
    height: 1.5,
    color: PuduuColors.soft,
  );
  static const strong = TextStyle(
    fontFamily: 'Work Sans',
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: PuduuColors.ink,
    height: 1.35,
  );
  static const meta = TextStyle(
    fontFamily: 'Work Sans',
    fontSize: 11.5,
    color: PuduuColors.mute,
    height: 1.4,
  );
}

/// ONE icon family per surface (M3/HIG): Material outlined, filled = active.
class PuduuIcons {
  static const today = Icons.calendar_today_outlined;
  static const todayFill = Icons.calendar_today;
  static const focus = Icons.timer_outlined;
  static const focusFill = Icons.timer;
  static const reset = Icons.bolt_outlined;
  static const resetFill = Icons.bolt;
  static const grows = Icons.bar_chart_outlined;
  static const growsFill = Icons.bar_chart;
  static const yours = Icons.settings_outlined;
  static const yoursFill = Icons.settings;
  static const search = Icons.search;
  static const bell = Icons.notifications_outlined;
  static const play = Icons.play_arrow;
  static const pause = Icons.pause;
  static const check = Icons.check;
  static const plus = Icons.add;
  static const chevron = Icons.chevron_right;
  static const drop = Icons.water_drop_outlined;
  static const walk = Icons.directions_walk;
  static const mail = Icons.mail_outline;
  static const sort = Icons.auto_awesome_outlined;
  static const crown = Icons.workspace_premium_outlined;
  static const sound = Icons.volume_up_outlined;
  static const shield = Icons.shield_outlined;
}

ThemeData puduuTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: PuduuColors.teal,
    onPrimary: Colors.white,
    secondary: PuduuColors.tealDeep,
    onSecondary: Colors.white,
    tertiary: PuduuColors.moss,
    onTertiary: Colors.white,
    error: PuduuColors.danger,
    onError: Colors.white,
    surface: PuduuColors.card,
    onSurface: PuduuColors.ink,
    surfaceContainerLow: PuduuColors.bg,
    onSurfaceVariant: PuduuColors.soft,
    outline: PuduuColors.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PuduuColors.bg,
    fontFamily: 'Work Sans',
    dividerTheme: const DividerThemeData(
      color: PuduuColors.line,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: PuduuColors.bg,
      foregroundColor: PuduuColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: PuduuColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: PuduuColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PuduuColors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PuduuColors.tealDeep,
        textStyle: const TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PuduuColors.card,
      hintStyle: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 13.5,
        color: PuduuColors.mute,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: PuduuColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: PuduuColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            const BorderSide(color: PuduuColors.teal, width: 1.4),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: PuduuColors.dark,
      indicatorColor: Colors.white,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 10,
          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
          color: sel ? Colors.white : const Color(0xFF8FA3A1),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return IconThemeData(
          color: sel ? PuduuColors.dark : const Color(0xFF8FA3A1),
          size: 22,
        );
      }),
    ),
  );
}
