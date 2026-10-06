import 'package:flutter/material.dart';

/// Puduu tokens v11 — "Aurora Gloss".
/// Calm brand, premium finish: light aurora background, glass cards with a
/// top sheen, tinted depth (never grey shadows), one teal accent with light.
class PuduuColors {
  static const bg = Color(0xFFF3F7F6);
  static const card = Color(0xFFFFFFFF);
  static const cardDeep = Color(0xFFF6FAF9);
  static const ink = Color(0xFF0F1F1E);
  static const soft = Color(0xFF3E5452);
  static const mute = Color(0xFF7A8F8D);
  static const line = Color(0xFFE4EBEA);
  static const teal = Color(0xFF0E9384);
  static const tealDeep = Color(0xFF0B6B5F);
  static const mint = Color(0xFF2DD4BF);
  static const amber = Color(0xFFF59E0B);
  static const peach = Color(0xFFFDBA74);
  static const moss = Color(0xFF4D7C0F);
  static const lime = Color(0xFFA3E635);
  static const sky = Color(0xFF0EA5E9);
  static const ice = Color(0xFF7DD3FC);
  static const lav = Color(0xFF8B5CF6);
  static const lilac = Color(0xFFC4B5FD);
  static const gold = Color(0xFFEAB308);
  static const goldDeep = Color(0xFFB45309);
  static const dark = Color(0xFF0B1F1D);
  static const danger = Color(0xFFDC2626);

  // legacy washes (kept for API compat)
  static const tealWash = Color(0xFFDDF3F0);
  static const amberWash = Color(0xFFFEF3DF);
  static const mossWash = Color(0xFFEFF6DF);
}

/// Gloss material: gradients, tinted shadows, radii, sheens.
class PuduuGloss {
  PuduuGloss._();

  // ---------- gradients ----------
  static const heroTeal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B3B36), Color(0xFF0E9384), Color(0xFF14B8A6)],
    stops: [0.0, 0.55, 1.0],
  );
  static const btnTeal = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1FB69F), Color(0xFF0E9384), Color(0xFF0B6B5F)],
    stops: [0.0, 0.45, 1.0],
  );
  static const cardSheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF6FAF9)],
    stops: [0.0, 1.0],
  );
  /// white 55% -> transparent across the top 35%: the "gloss" streak.
  static const topSheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x8CFFFFFF), Color(0x00FFFFFF)],
    stops: [0.0, 0.38],
  );
  static const barTeal = LinearGradient(
    colors: [Color(0xFF2DD4BF), Color(0xFF0E9384)],
  );
  static const goldSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDE68A), Color(0xFFEAB308), Color(0xFFB45309)],
  );
  static const tileFocus =
      LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF7DD3FC)]);
  static const tileReset =
      LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFDBA74)]);
  static const tileHabits =
      LinearGradient(colors: [Color(0xFF65A30D), Color(0xFFA3E635)]);
  static const tileEvening =
      LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFC4B5FD)]);

  // aurora blobs for the page background
  static const blobMint = Color(0xFFDDF3F0);
  static const blobPeach = Color(0xFFFDEBD3);
  static const blobLilac = Color(0xFFE9E4FA);

  // ---------- tinted shadows (depth is colored, never grey) ----------
  static List<BoxShadow> cardShadow([Color tint = PuduuColors.teal]) => [
        BoxShadow(
          color: tint.withAlpha(30),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
  static List<BoxShadow> glow([Color tint = PuduuColors.teal]) => [
        BoxShadow(
          color: tint.withAlpha(90),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ];

  // ---------- radii ----------
  static const rCard = 24.0;
  static const rHero = 28.0;
  static const rPill = 999.0;
  static const rTile = 20.0;
  static const rInput = 20.0;

  // ---------- glass ----------
  static const glassWhite = Color(0xB8FFFFFF); // 72%
  static const glassBorder = Color(0x66FFFFFF); // 40%
}

class PuduuType {
  static const display = TextStyle(
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w700,
    color: PuduuColors.ink,
    height: 1.12,
    letterSpacing: -0.5,
  );
  static const title = TextStyle(
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w600,
    color: PuduuColors.ink,
    height: 1.25,
    letterSpacing: -0.2,
  );
  static TextStyle label([Color color = PuduuColors.tealDeep]) => TextStyle(
        fontFamily: 'Outfit',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
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
      backgroundColor: Colors.transparent,
      foregroundColor: PuduuColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: PuduuColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PuduuGloss.rCard),
        side: const BorderSide(color: PuduuGloss.glassBorder),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PuduuColors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
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
      fillColor: PuduuGloss.glassWhite,
      hintStyle: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 13.5,
        color: PuduuColors.mute,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PuduuGloss.rInput),
        borderSide: const BorderSide(color: PuduuGloss.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PuduuGloss.rInput),
        borderSide: const BorderSide(color: PuduuGloss.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PuduuGloss.rInput),
        borderSide:
            const BorderSide(color: PuduuColors.teal, width: 1.6),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
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
