library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.backgroundLift,
    required this.panelFill,
    required this.panelHighlight,
    required this.panelBorder,
    required this.text,
    required this.textDim,
    required this.textMute,
    required this.gold,
    required this.goldBright,
    required this.goldDeep,
    required this.danger,
    required this.pageGradient,
    required this.shadow,
  });

  final Brightness brightness;

  final Color background;

  final Color backgroundLift;

  final Color panelFill;

  final Color panelHighlight;

  final Color panelBorder;

  final Color text;
  final Color textDim;
  final Color textMute;

  final Color gold;
  final Color goldBright;
  final Color goldDeep;

  final Color danger;

  final Gradient pageGradient;

  final Color shadow;

  bool get isDark => brightness == Brightness.dark;

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF15100B),
    backgroundLift: Color(0xFF1C1610),
    panelFill: Color(0x0DFFFFFF),
    panelHighlight: Color(0x1FD8A943),
    panelBorder: Color(0x29D8A943),
    text: Color(0xFFEFE4CB),
    textDim: Color(0xFFA48D68),
    textMute: Color(0xFF7C6A4A),
    gold: Color(0xFFD8A943),
    goldBright: Color(0xFFE6BB55),
    goldDeep: Color(0xFFB98A2C),
    danger: Color(0xFFDF9476),
    shadow: Color(0x99000000),
    pageGradient: RadialGradient(
      center: Alignment(-0.65, -1),
      radius: 1.35,
      colors: [Color(0xFF2C1D11), Color(0xFF15100B)],
      stops: [0.0, 0.62],
    ),
  );

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF6EFE1),
    backgroundLift: Color(0xFFFFFBF3),
    panelFill: Color(0xA8FFFFFF),
    panelHighlight: Color(0x2EB9892C),
    panelBorder: Color(0x3D9A763A),
    text: Color(0xFF2C1E0C),
    textDim: Color(0xFF7A6342),
    textMute: Color(0xFF9C8762),
    gold: Color(0xFFA9751F),
    goldBright: Color(0xFFC9942F),
    goldDeep: Color(0xFF835815),
    danger: Color(0xFFB0472A),
    shadow: Color(0x2E3A2510),
    pageGradient: RadialGradient(
      center: Alignment(-0.65, -1),
      radius: 1.35,
      colors: [Color(0xFFFFF9EC), Color(0xFFEFE4CE)],
      stops: [0.0, 0.72],
    ),
  );

  @override
  AppPalette copyWith({Brightness? brightness}) => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}

abstract final class BoardColors {
  static const Color walnutDeep = Color(0xFF241509);
  static const Color walnut = Color(0xFF3F2817);
  static const Color walnutEdge = Color(0xFF54371F);

  static const Color squareDark = Color(0xFF7A4A26);
  static const Color squareDark2 = Color(0xFF6D4121);
  static const Color squareLight = Color(0xFFE8D2A6);
  static const Color squareLight2 = Color(0xFFDDC394);

  static const Color ivory = Color(0xFFF4EAD4);
  static const Color ivoryEdge = Color(0xFFCDBF9C);
  static const Color charcoal = Color(0xFF221C17);
  static const Color charcoalEdge = Color(0xFF0C0907);

  static const Color accent = Color(0xFFD8A943);
  static const Color accentBright = Color(0xFFE6BB55);

  static const LinearGradient frameGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [walnutEdge, walnut, walnutDeep],
    stops: [0.0, 0.42, 1.0],
  );
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}

abstract final class AppSpacing {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 32;

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(10));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(14));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(20));
}

abstract final class AppText {
  static const TextStyle brand = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: 4,
    height: 1.1,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(fontSize: 14.5, height: 1.55);

  static const TextStyle bodyDim = TextStyle(fontSize: 14, height: 1.55);

  static const TextStyle label = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.1,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

}

ThemeData buildAppTheme(Brightness brightness) {
  final palette =
      brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: palette.gold,
    onPrimary: brightness == Brightness.dark
        ? const Color(0xFF2A1C0A)
        : const Color(0xFFFFF8EA),
    secondary: palette.goldBright,
    onSecondary: const Color(0xFF2A1C0A),
    surface: palette.backgroundLift,
    onSurface: palette.text,
    error: palette.danger,
    onError: const Color(0xFFFFF8EA),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.background,
    splashFactory: InkSparkle.splashFactory,
    extensions: [palette],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: palette.text),
      titleTextStyle: AppText.title.copyWith(color: palette.text),
      systemOverlayStyle: systemOverlayFor(palette),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.backgroundLift,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.radiusLg),
      titleTextStyle: AppText.title.copyWith(color: palette.text),
      contentTextStyle: AppText.bodyDim.copyWith(color: palette.textDim),
    ),
    textTheme: TextTheme(
      bodyMedium: AppText.body.copyWith(color: palette.text),
      bodySmall: AppText.bodyDim.copyWith(color: palette.textDim),
      titleMedium: AppText.sectionTitle.copyWith(color: palette.text),
      titleLarge: AppText.title.copyWith(color: palette.text),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.gold
            : palette.textMute,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.gold.withValues(alpha: 0.32)
            : palette.textMute.withValues(alpha: 0.18),
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    listTileTheme: ListTileThemeData(
      textColor: palette.text,
      iconColor: palette.textDim,
    ),
    dividerTheme: DividerThemeData(
      color: palette.panelBorder,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.backgroundLift,
      contentTextStyle: AppText.body.copyWith(color: palette.text),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.radiusMd),
    ),
  );
}

SystemUiOverlayStyle systemOverlayFor(AppPalette palette) {
  final icons = palette.isDark ? Brightness.light : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: icons,
    statusBarBrightness: palette.brightness,
    systemNavigationBarColor: palette.background,
    systemNavigationBarIconBrightness: icons,
  );
}
