import 'package:flutter/material.dart';

/// Tokens that must flip between light and dark ("Liquid Glass" surfaces are
/// literally translucent white in light mode — that reads as a light leak on
/// a dark canvas, so they need a dark counterpart, not just an inverted
/// text color). Brand accents (mint/coral/status colors) stay in [AppTheme]
/// since they read fine unchanged in both modes.
///
/// Access via `context.glass` rather than `Theme.of(context).extension<...>()`.
@immutable
class GlassColors extends ThemeExtension<GlassColors> {
  const GlassColors({
    required this.ink,
    required this.muted,
    required this.canvasTop,
    required this.canvasMid,
    required this.canvasBottom,
    required this.surface,
    required this.surfaceBorder,
    required this.mintPale,
    required this.coralPale,
  });

  /// Primary text color.
  final Color ink;

  /// Secondary/caption text color.
  final Color muted;

  /// Background gradient stops painted by [GlassBackground].
  final Color canvasTop;
  final Color canvasMid;
  final Color canvasBottom;

  /// Base tint for frosted glass surfaces (cards, dialogs, nav bars) before
  /// opacity is applied — `Colors.white` in light mode, a dark slate in dark
  /// mode, so blurred surfaces lighten in light mode and stay dark in dark
  /// mode instead of turning into a bright patch.
  final Color surface;

  /// The subtle "lensing" edge highlight glass surfaces are outlined with.
  final Color surfaceBorder;

  /// Pale brand tints used for icon backgrounds/chips over a card.
  final Color mintPale;
  final Color coralPale;

  static const light = GlassColors(
    ink: Color(0xFF162238),
    muted: Color(0xFF6B7686),
    canvasTop: Color(0xFFEAF1FF),
    canvasMid: Color(0xFFF3F6FB),
    canvasBottom: Color(0xFFEFFCF8),
    surface: Colors.white,
    surfaceBorder: Colors.white,
    mintPale: Color(0xFFDFFBF3),
    coralPale: Color(0xFFFFE7E4),
  );

  static const dark = GlassColors(
    ink: Color(0xFFEAF1F7),
    muted: Color(0xFF93A2B8),
    canvasTop: Color(0xFF0B1220),
    canvasMid: Color(0xFF0E1626),
    canvasBottom: Color(0xFF0A1B18),
    surface: Color(0xFF1B2536),
    surfaceBorder: Colors.white,
    mintPale: Color(0xFF163430),
    coralPale: Color(0xFF3A211F),
  );

  @override
  GlassColors copyWith({
    Color? ink,
    Color? muted,
    Color? canvasTop,
    Color? canvasMid,
    Color? canvasBottom,
    Color? surface,
    Color? surfaceBorder,
    Color? mintPale,
    Color? coralPale,
  }) {
    return GlassColors(
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      canvasTop: canvasTop ?? this.canvasTop,
      canvasMid: canvasMid ?? this.canvasMid,
      canvasBottom: canvasBottom ?? this.canvasBottom,
      surface: surface ?? this.surface,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      mintPale: mintPale ?? this.mintPale,
      coralPale: coralPale ?? this.coralPale,
    );
  }

  @override
  GlassColors lerp(ThemeExtension<GlassColors>? other, double t) {
    if (other is! GlassColors) return this;
    return GlassColors(
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      canvasTop: Color.lerp(canvasTop, other.canvasTop, t)!,
      canvasMid: Color.lerp(canvasMid, other.canvasMid, t)!,
      canvasBottom: Color.lerp(canvasBottom, other.canvasBottom, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      mintPale: Color.lerp(mintPale, other.mintPale, t)!,
      coralPale: Color.lerp(coralPale, other.coralPale, t)!,
    );
  }
}

/// Shorthand for `Theme.of(context).extension<GlassColors>()!`.
extension GlassColorsX on BuildContext {
  GlassColors get glass => Theme.of(this).extension<GlassColors>()!;
}

/// Design tokens and [ThemeData] for Pillmo's Liquid Glass–inspired look:
/// translucent, blurred surfaces floating over a soft gradient canvas,
/// concentric rounded shapes, and a single tinted accent per screen.
abstract final class AppTheme {
  // Brand accents — tint sparingly, only the primary action per screen.
  // Unlike [GlassColors], these stay the same across light and dark: they're
  // already saturated enough to read on both a light and a dark canvas.
  static const mint = Color(0xFF2FD9C2);
  static const mintDeep = Color(0xFF17B39D);
  static const coral = Color(0xFFFF7A70);

  // Semantic status colors, used instead of raw Material colors.
  static const success = Color(0xFF15B37D);
  static const warning = Color(0xFFE0932E);
  static const danger = Color(0xFFE0524A);
  static const info = Color(0xFF4C7EF3);

  static const glassShadow = Color(0x1A16233D);

  static ThemeData get light => _theme(Brightness.light, GlassColors.light);
  static ThemeData get dark => _theme(Brightness.dark, GlassColors.dark);

  static ThemeData _theme(Brightness brightness, GlassColors glass) {
    final ink = glass.ink;
    final muted = glass.muted;
    final onGlassSurface = glass.surface;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mint,
        brightness: brightness,
        primary: mintDeep,
        onPrimary: Colors.white,
        secondary: coral,
        surface: brightness == Brightness.light ? Colors.white : glass.surface,
      ),
      extensions: [glass],
    );

    return base.copyWith(
      scaffoldBackgroundColor: glass.canvasMid,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            color: ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -.4),
      ),
      textTheme: base.textTheme.copyWith(
        displaySmall: TextStyle(
            color: ink, fontWeight: FontWeight.w800, letterSpacing: -.6),
        headlineSmall: TextStyle(
            color: ink, fontWeight: FontWeight.w800, letterSpacing: -.4),
        titleLarge: TextStyle(
            color: ink, fontWeight: FontWeight.w800, letterSpacing: -.2),
        titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(color: ink, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: ink, height: 1.35),
        bodyMedium: TextStyle(color: muted, height: 1.4),
        labelLarge: TextStyle(
            color: ink, fontWeight: FontWeight.w700, letterSpacing: .1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: onGlassSurface.withOpacity(.55),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: glass.surfaceBorder.withOpacity(.7), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: glass.surfaceBorder.withOpacity(.7), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: mintDeep, width: 2),
        ),
        labelStyle: TextStyle(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: mintDeep,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: onGlassSurface.withOpacity(.7),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: StadiumBorder(
            side: BorderSide(color: glass.surfaceBorder, width: 1.2),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mintDeep,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: glass.mintPale,
          foregroundColor: mintDeep,
          shape: const CircleBorder(),
        ),
      ),
      cardTheme: CardTheme(
        color: onGlassSurface.withOpacity(.82),
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: glassShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side:
              BorderSide(color: glass.surfaceBorder.withOpacity(.9), width: 1),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: onGlassSurface.withOpacity(.96),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle:
            TextStyle(color: ink, fontSize: 19, fontWeight: FontWeight.w800),
      ),
      // showTimePicker/showDatePicker otherwise fall back to stock Material3
      // dialogs, which clash with the rest of the app's rounded, translucent
      // "Liquid Glass" surfaces and mint/coral accents.
      timePickerTheme: TimePickerThemeData(
        backgroundColor: onGlassSurface.withOpacity(.96),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        helpTextStyle: TextStyle(color: muted, fontWeight: FontWeight.w700),
        dayPeriodShape: const StadiumBorder(),
        dayPeriodColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected) ? mintDeep : glass.mintPale),
        dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.white : mintDeep),
        hourMinuteShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        hourMinuteColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? glass.mintPale
                : onGlassSurface.withOpacity(.6)),
        hourMinuteTextColor: ink,
        dialBackgroundColor: glass.mintPale,
        dialHandColor: mintDeep,
        dialTextColor: ink,
        entryModeIconColor: mintDeep,
        confirmButtonStyle: TextButton.styleFrom(
            foregroundColor: mintDeep,
            textStyle: const TextStyle(fontWeight: FontWeight.w800)),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: muted),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: onGlassSurface.withOpacity(.96),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        headerBackgroundColor: mintDeep,
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: const TextStyle(fontWeight: FontWeight.w800),
        weekdayStyle: TextStyle(color: muted, fontWeight: FontWeight.w700),
        todayForegroundColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.white : mintDeep),
        todayBackgroundColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? mintDeep
                : Colors.transparent),
        todayBorder: const BorderSide(color: mintDeep, width: 1.2),
        dayForegroundColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.white : ink),
        dayBackgroundColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? mintDeep
                : Colors.transparent),
        dayOverlayColor: WidgetStateColor.resolveWith(
            (states) => glass.mintPale.withOpacity(.5)),
        yearForegroundColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.white : ink),
        yearBackgroundColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? mintDeep
                : Colors.transparent),
        rangePickerBackgroundColor: onGlassSurface.withOpacity(.96),
        confirmButtonStyle: TextButton.styleFrom(
            foregroundColor: mintDeep,
            textStyle: const TextStyle(fontWeight: FontWeight.w800)),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: muted),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: onGlassSurface.withOpacity(.96),
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: muted.withOpacity(.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      // A fixed dark chip in both modes — same idiom as a system toast, not
      // meant to invert with theme brightness like the rest of the surfaces.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF162238),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: mintDeep.withOpacity(.16),
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? mintDeep : muted,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? mintDeep : muted,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: coral,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: CircleBorder(),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: mintDeep,
      ),
      dividerTheme: DividerThemeData(
          color: glass.surfaceBorder.withOpacity(.6), space: 1),
    );
  }
}
