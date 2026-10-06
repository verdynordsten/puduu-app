import 'package:flutter/material.dart';

/// Puduu tokens v12 — "Candy Pop".
/// TOTAL rebuild: cream canvas, chunky 3px ink borders, hard offset shadows,
/// loud candy colors, Baloo 2 display + Nunito UI. Nothing of v10/v11 remains.
class PuduuColors {
  static const cream = Color(0xFFFFF3DC);
  static const paper = Color(0xFFFFFFFF);
  static const ink = Color(0xFF2A2320);
  static const cocoa = Color(0xFF6B5D52);
  static const clay = Color(0xFFA89880);

  static const coral = Color(0xFFFF5C6C);
  static const coralDeep = Color(0xFFE8445A);
  static const sun = Color(0xFFFFC53D);
  static const sunDeep = Color(0xFFF0A41E);
  static const grape = Color(0xFF7C5CFF);
  static const grapeDeep = Color(0xFF5F3DF0);
  static const mint = Color(0xFF2ED3A3);
  static const mintDeep = Color(0xFF1DA87F);
  static const sky = Color(0xFF4FC3F7);
  static const skyDeep = Color(0xFF2AA5DE);
  static const blush = Color(0xFFFFD9E0);
  static const butter = Color(0xFFFFE9B8);
  static const lilac = Color(0xFFE3D9FF);
  static const frost = Color(0xFFD8F4E8);

  static const danger = Color(0xFFE8445A);
}

/// Chunky material: hard offset shadows, thick ink borders, big radii.
class PopStyle {
  PopStyle._();

  static const borderW = 2.0;
  static const rCard = 24.0;
  static const rHero = 30.0;
  static const rPill = 999.0;
  static const rTile = 20.0;
  static const rInput = 18.0;

  static Border inkBorder([double w = borderW]) =>
      Border.all(color: PuduuColors.ink, width: w);

  /// The signature hard shadow: solid ink offset, zero blur.
  static List<BoxShadow> hardShadow(
          {Color color = PuduuColors.ink,
          double dx = 4,
          double dy = 4}) =>
      [
        BoxShadow(
            color: color, offset: Offset(dx, dy), blurRadius: 0),
      ];

  /// Tinted hard shadow for colored surfaces.
  static List<BoxShadow> popShadow(Color tint) => [
        BoxShadow(
            color: tint, offset: const Offset(4, 4), blurRadius: 0),
      ];
}

class PuduuType {
  static const display = TextStyle(
    fontFamily: 'Baloo2',
    fontWeight: FontWeight.w800,
    color: PuduuColors.ink,
    height: 1.05,
    letterSpacing: -0.3,
  );
  static const title = TextStyle(
    fontFamily: 'Baloo2',
    fontWeight: FontWeight.w700,
    color: PuduuColors.ink,
    height: 1.15,
    letterSpacing: -0.2,
  );
  static TextStyle label([Color color = PuduuColors.cocoa]) =>
      TextStyle(
        fontFamily: 'Baloo2',
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: color,
      );
  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    height: 1.5,
    color: PuduuColors.cocoa,
    fontWeight: FontWeight.w600,
  );
  static const strong = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: PuduuColors.ink,
    height: 1.35,
  );
  static const meta = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: PuduuColors.clay,
    height: 1.4,
  );
}

/// Rounded icon family — playful, matches the chunky shapes.
class PuduuIcons {
  static const today = Icons.calendar_month_rounded;
  static const todayFill = Icons.calendar_month_rounded;
  static const focus = Icons.timer_rounded;
  static const focusFill = Icons.timer_rounded;
  static const reset = Icons.bolt_rounded;
  static const resetFill = Icons.bolt_rounded;
  static const grows = Icons.bar_chart_rounded;
  static const growsFill = Icons.bar_chart_rounded;
  static const yours = Icons.settings_rounded;
  static const yoursFill = Icons.settings_rounded;
  static const search = Icons.search_rounded;
  static const bell = Icons.notifications_rounded;
  static const play = Icons.play_arrow_rounded;
  static const pause = Icons.pause_rounded;
  static const check = Icons.check_rounded;
  static const plus = Icons.add_rounded;
  static const chevron = Icons.chevron_right_rounded;
  static const drop = Icons.water_drop_rounded;
  static const walk = Icons.directions_walk_rounded;
  static const mail = Icons.mail_rounded;
  static const sort = Icons.auto_awesome_rounded;
  static const crown = Icons.workspace_premium_rounded;
  static const sound = Icons.volume_up_rounded;
  static const shield = Icons.shield_rounded;
}

ThemeData puduuTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: PuduuColors.coral,
    onPrimary: Colors.white,
    secondary: PuduuColors.sun,
    onSecondary: PuduuColors.ink,
    tertiary: PuduuColors.grape,
    onTertiary: Colors.white,
    error: PuduuColors.danger,
    onError: Colors.white,
    surface: PuduuColors.paper,
    onSurface: PuduuColors.ink,
    surfaceContainerLow: PuduuColors.cream,
    onSurfaceVariant: PuduuColors.cocoa,
    outline: PuduuColors.ink,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PuduuColors.cream,
    fontFamily: 'Nunito',
    dividerTheme: const DividerThemeData(
      color: PuduuColors.ink,
      thickness: 2,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: PuduuColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: PuduuColors.paper,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PopStyle.rCard),
        side: BorderSide(
            color: PuduuColors.ink, width: PopStyle.borderW),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PuduuColors.coral,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
              color: PuduuColors.ink, width: PopStyle.borderW),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        textStyle: const TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PuduuColors.grapeDeep,
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PuduuColors.paper,
      hintStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: PuduuColors.clay,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PopStyle.rInput),
        borderSide: const BorderSide(
            color: PuduuColors.ink, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PopStyle.rInput),
        borderSide: const BorderSide(
            color: PuduuColors.ink, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PopStyle.rInput),
        borderSide: const BorderSide(
            color: PuduuColors.grape, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: Colors.white,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Nunito',
          fontSize: 10.5,
          fontWeight: sel ? FontWeight.w800 : FontWeight.w700,
          color: sel ? PuduuColors.ink : PuduuColors.clay,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return IconThemeData(
          color: sel ? PuduuColors.ink : PuduuColors.clay,
          size: 23,
        );
      }),
    ),
  );
}
