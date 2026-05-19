import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';

enum AppTheme {
  light,
  dark,
  system;

  static AppTheme fromString(String? value) {
    return switch (value) {
      'light' => AppTheme.light,
      'dark' => AppTheme.dark,
      'system' => AppTheme.system,
      _ => AppTheme.system,
    };
  }

  String title(BuildContext context) => switch (this) {
        light => AppLocalizations.of(context).lightMode,
        dark => AppLocalizations.of(context).darkMode,
        system => AppLocalizations.of(context).system,
      };

  bool get isDarkMode => switch (this) {
        AppTheme.light => false,
        AppTheme.dark => true,
        AppTheme.system =>
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark,
      };

  TextTheme get textTheme =>
      isDarkMode ? darkTheme.textTheme : lightTheme.textTheme;
}

const String appFontFamily = 'Montserrat';

const TextTheme appTextTheme = TextTheme(
  // Display
  displayLarge: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 57,
    height: 64 / 57,
    letterSpacing: -0.25,
    fontWeight: FontWeight.w400,
  ),
  displayMedium: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 45,
    height: 52 / 45,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  ),
  displaySmall: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 36,
    height: 44 / 36,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  ),

  // Headline
  headlineLarge: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  ),
  headlineMedium: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 28,
    height: 36 / 28,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  ),
  headlineSmall: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  ),

  // Title
  titleLarge: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
  ), // M3 uses w500, M2 used w400
  titleMedium: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w500,
  ),
  titleSmall: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
  ),

  // Label
  labelLarge: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  ),
  labelMedium: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w700,
  ),
  labelSmall: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w700,
  ),

  // Body
  bodyLarge: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w400,
  ), // M3 uses 0.15, M2 used 0.5
  bodyMedium: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w400,
  ),
  // Your custom Body Small
  bodySmall: TextStyle(
    fontFamily: appFontFamily,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w400,
  ),
);

class AppColors {
  // Primary Tonal Palette
  static const Color primary0 = Color(0xFF000000);
  static const Color primary10 = Color(0xFF001F29);
  static const Color primary20 = Color(0xFF003544);
  static const Color primary30 = Color(0xFF004D62);
  static const Color primary40 = Color(0xFF006781);
  static const Color primary50 = Color(0xFF0082A1);
  static const Color primary60 = Color(0xFF009DC3);
  static const Color primary70 = Color(0xFF00BAE6);
  static const Color primary80 = Color(0xFF57D5FF);
  static const Color primary90 = Color(0xFFB9EAFF);
  static const Color primary95 = Color(0xFFDEF4FF);
  static const Color primary99 = Color(0xFFFAFDFF);
  static const Color primary100 = Color(0xFFFFFFFF);

  // Secondary Tonal Palette
  static const Color secondary0 = Color(0xFF000000);
  static const Color secondary10 = Color(0xFF031F28);
  static const Color secondary20 = Color(0xFF1A343D);
  static const Color secondary30 = Color(0xFF314A54);
  static const Color secondary40 = Color(0xFF49626D);
  static const Color secondary50 = Color(0xFF617B86);
  static const Color secondary60 = Color(0xFF7B95A0);
  static const Color secondary70 = Color(0xFF95AFBB);
  static const Color secondary80 = Color(0xFFB0CBD7);
  static const Color secondary90 = Color(0xFFCCE7F3);
  static const Color secondary95 = Color(0xFFDEF4FF);
  static const Color secondary99 = Color(0xFFFAFDFF);
  static const Color secondary100 = Color(0xFFFFFFFF);

  // Tertiary Tonal Palette
  static const Color tertiary0 = Color(0xFF000000);
  static const Color tertiary10 = Color(0xFF241A00);
  static const Color tertiary20 = Color(0xFF3D2F00);
  static const Color tertiary30 = Color(0xFF584400);
  static const Color tertiary40 = Color(0xFF745B00);
  static const Color tertiary50 = Color(0xFF927300);
  static const Color tertiary60 = Color(0xFFB08C00);
  static const Color tertiary70 = Color(0xFFD0A600);
  static const Color tertiary80 = Color(0xFFF1C100);
  static const Color tertiary90 = Color(0xFFFFE08B);
  static const Color tertiary95 = Color(0xFFFFEFCD);
  static const Color tertiary99 = Color(0xFFFFFBFF);
  static const Color tertiary100 = Color(0xFFFFFFFF);

  // Error Tonal Palette
  static const Color error0 = Color(0xFF000000);
  static const Color error10 = Color(0xFF410002);
  static const Color error20 = Color(0xFF690005);
  static const Color error30 = Color(0xFF93000A);
  static const Color error40 = Color(0xFFBA1A1A);
  static const Color error50 = Color(0xFFDE3730);
  static const Color error60 = Color(0xFFFF5449);
  static const Color error70 = Color(0xFFFF897D);
  static const Color error80 = Color(0xFFFFB4AB);
  static const Color error90 = Color(0xFFFFDAD6);
  static const Color error95 = Color(0xFFFFEDEA);
  static const Color error99 = Color(0xFFFFFBFF);
  static const Color error100 = Color(0xFFFFFFFF);

  // Neutral Tonal Palette (Backgrounds, Surfaces)
  static const Color neutral0 = Color(0xFF000000);
  static const Color neutral10 = Color(0xFF191C1D);
  static const Color neutral20 = Color(0xFF2E3132);
  static const Color neutral30 = Color(0xFF444749);
  static const Color neutral40 = Color(0xFF5C5F60);
  static const Color neutral50 = Color(0xFF757779);
  static const Color neutral60 = Color(0xFF8F9193);
  static const Color neutral70 = Color(0xFFA9ABAD);
  static const Color neutral80 = Color(0xFFC5C7C8);
  static const Color neutral90 = Color(0xFFE1E3E4);
  static const Color neutral95 = Color(0xFFEFF1F2);
  static const Color neutral99 = Color(0xFFFBFCFE);
  static const Color neutral100 = Color(0xFFFFFFFF);

  // Neutral Variant Tonal Palette (Surface Variants, Outlines)
  static const Color neutralVariant0 = Color(0xFF000000);
  static const Color neutralVariant10 = Color(0xFF151D20);
  static const Color neutralVariant20 = Color(0xFF2A3235);
  static const Color neutralVariant30 = Color(0xFF40484C);
  static const Color neutralVariant40 = Color(0xFF576064);
  static const Color neutralVariant50 = Color(0xFF70787C);
  static const Color neutralVariant60 = Color(0xFF8A9296);
  static const Color neutralVariant70 = Color(0xFFA4ACB1);
  static const Color neutralVariant80 = Color(0xFFC0C8CC);
  static const Color neutralVariant90 = Color(0xFFDCE4E8);
  static const Color neutralVariant95 = Color(0xFFEAF2F7);
  static const Color neutralVariant99 = Color(0xFFFAFDFF);
  static const Color neutralVariant100 = Color(0xFFFFFFFF);

  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2A37);
  static const Color gray900 = Color(0xFF111928);

  static const Color yellow100 = Color(0xFFFDF6B2);
  static const Color yellow300 = Color(0xFFFACA15);
  static const Color yellow400 = Color(0xFFE3A008);

  static const Color red100 = Color(0xFFFDE8E8);
  static const Color red700 = Color(0xFFC81E1E);

  /// Select-route map: polyline + label for the app’s currently chosen route.
  static const Color mapSelectedRouteLight = primary40;
  static const Color mapSelectedRouteDark = primary80;

  // Overlay colors
  static const Color barrierColor = Color(0x80000000); // black with 50% opacity
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,

    // Primary part
    primary: AppColors.primary40,
    onPrimary: AppColors.primary100,
    primaryContainer: AppColors.primary90,
    onPrimaryContainer: AppColors.primary30,
    primaryFixed: AppColors.primary90,
    primaryFixedDim: AppColors.primary80,
    onPrimaryFixed: AppColors.primary10,
    onPrimaryFixedVariant: AppColors.primary30,

    // Secondary part
    secondary: AppColors.secondary40,
    onSecondary: AppColors.secondary100,
    secondaryContainer: AppColors.secondary90,
    onSecondaryContainer: AppColors.secondary30,
    secondaryFixed: AppColors.secondary90,
    secondaryFixedDim: AppColors.secondary80,
    onSecondaryFixed: AppColors.secondary10,
    onSecondaryFixedVariant: AppColors.secondary30,

    // Tertiary part
    tertiary: AppColors.tertiary40,
    onTertiary: AppColors.tertiary100,
    tertiaryContainer: AppColors.tertiary90,
    onTertiaryContainer: AppColors.tertiary30,
    tertiaryFixed: AppColors.tertiary90,
    tertiaryFixedDim: AppColors.tertiary80,
    onTertiaryFixed: AppColors.tertiary10,
    onTertiaryFixedVariant: AppColors.tertiary30,

    // Error part
    error: AppColors.error40,
    onError: AppColors.error100,
    errorContainer: AppColors.error90,
    onErrorContainer: AppColors.error30,

    // Surface part
    surfaceDim: AppColors.neutral80,
    surfaceBright: AppColors.neutral99,
    surface: AppColors.neutral99,
    surfaceContainerLow: AppColors.neutral95,
    surfaceContainerLowest: AppColors.neutral100,
    surfaceContainer: AppColors.neutral95,
    surfaceContainerHigh: AppColors.neutral90,
    surfaceContainerHighest: AppColors.neutral90,
    onSurface: AppColors.neutral10,
    onSurfaceVariant: AppColors.neutralVariant30,
    outline: AppColors.neutralVariant50,
    outlineVariant: AppColors.neutralVariant80,
    inverseSurface: AppColors.neutral20,
    onInverseSurface: AppColors.neutral90,
    inversePrimary: AppColors.primary80,
    scrim: AppColors.neutral0,
    shadow: AppColors.neutral0,
  ),
  fontFamily: appFontFamily,
  textTheme: appTextTheme.apply(
    bodyColor: AppColors.primary0,
    displayColor: AppColors.primary0,
  ),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    // Primary part
    primary: AppColors.primary80,
    onPrimary: AppColors.primary20,
    primaryContainer: AppColors.primary30,
    onPrimaryContainer: AppColors.primary90,
    primaryFixed: AppColors.primary90,
    primaryFixedDim: AppColors.primary80,
    onPrimaryFixed: AppColors.primary10,
    onPrimaryFixedVariant: AppColors.primary30,

    // Secondary part
    secondary: AppColors.secondary80,
    onSecondary: AppColors.secondary20,
    secondaryContainer: AppColors.secondary30,
    onSecondaryContainer: AppColors.secondary90,
    secondaryFixed: AppColors.secondary90,
    secondaryFixedDim: AppColors.secondary80,
    onSecondaryFixed: AppColors.secondary10,
    onSecondaryFixedVariant: AppColors.secondary30,

    // Tertiary part
    tertiary: AppColors.tertiary80,
    onTertiary: AppColors.tertiary20,
    tertiaryContainer: AppColors.tertiary30,
    onTertiaryContainer: AppColors.tertiary90,
    tertiaryFixed: AppColors.tertiary90,
    tertiaryFixedDim: AppColors.tertiary80,
    onTertiaryFixed: AppColors.tertiary10,
    onTertiaryFixedVariant: AppColors.tertiary30,

    // Error part
    error: AppColors.error80,
    onError: AppColors.error20,
    errorContainer: AppColors.error30,
    onErrorContainer: AppColors.error90,

    // Surface part
    surfaceDim: AppColors.neutral0,
    surfaceBright: AppColors.neutral20,
    surface: AppColors.neutral0,
    surfaceContainerLow: AppColors.neutral10,
    surfaceContainerLowest: AppColors.neutral0,
    surfaceContainer: AppColors.neutral10,
    surfaceContainerHigh: AppColors.neutral20,
    surfaceContainerHighest: AppColors.neutral20,
    onSurface: AppColors.neutral90,
    onSurfaceVariant: AppColors.neutralVariant80,
    outline: AppColors.neutralVariant60,
    outlineVariant: AppColors.neutralVariant30,
    inverseSurface: AppColors.neutral90,
    onInverseSurface: AppColors.neutral20,
    inversePrimary: AppColors.primary40,
    scrim: AppColors.neutral0,
    shadow: AppColors.neutral0,
  ),
  fontFamily: appFontFamily,
  textTheme: appTextTheme.apply(
    bodyColor: AppColors.primary100,
    displayColor: AppColors.primary100,
  ),
  useMaterial3: true,
);

extension ColorSchemeExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
