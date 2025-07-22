import 'package:flutter/material.dart';

class PhrazyColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color backgroundColorLight;
  final Color foregroundColorLight;
  final Color onBackgroundColor;
  final Color cardColor;
  final Color onCardColor;
  final Color textColor;
  final Color borderColor;
  final Color dialogColor;
  final Color yesColor;
  final Color noColor;
  final Color iconBackgroundColor;

  const PhrazyColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.backgroundColorLight,
    required this.foregroundColorLight,
    required this.onBackgroundColor,
    required this.cardColor,
    required this.onCardColor,
    required this.textColor,
    required this.borderColor,
    required this.dialogColor,
    required this.yesColor,
    required this.noColor,
    required this.iconBackgroundColor,
  });
}

const PhrazyColors defaultColors = PhrazyColors(
  backgroundColor: Color(0xFF5828D2),
  foregroundColor: Color(0xFF330697),
  backgroundColorLight: Color(0xFFA382FF),
  foregroundColorLight: Color(0xFFB4A7FF),
  onBackgroundColor: Colors.white,
  cardColor: Colors.white,
  onCardColor: Colors.black,
  textColor: Colors.white,
  borderColor: Colors.black,
  dialogColor: Colors.black,
  yesColor: Color(0xFF00FFC4),
  noColor: Color(0xFFFF007F),
  iconBackgroundColor: Colors.transparent,
);

const PhrazyColors highContrastColors = PhrazyColors(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  backgroundColorLight: Color(0xFF666666),
  foregroundColorLight: Color(0xFFAAAAAA),
  onBackgroundColor: Colors.black,
  cardColor: Colors.white,
  onCardColor: Colors.black,
  textColor: Colors.black,
  borderColor: Colors.black,
  dialogColor: Colors.white,
  yesColor: Color(0xFF00FFC4),
  noColor: Color(0xFFFF007F),
  iconBackgroundColor: Colors.white,
);

class Style {
  static const fontFamily = 'BioRhyme';

  static TextStyle get displayLarge {
    return const TextStyle(
      fontFamily: fontFamily,
      fontVariations: [
        FontVariation("wght", 800),
      ],
      fontSize: 44,
    );
  }

  static TextStyle get displayMedium => displayLarge.copyWith(fontSize: 32);

  static TextStyle get displaySmall => displayLarge.copyWith(fontSize: 20);

  static TextStyle get headlineLarge {
    return const TextStyle(
      fontFamily: fontFamily,
      fontVariations: [
        FontVariation("wght", 400),
      ],
      fontSize: 44,
    );
  }

  static TextStyle get headlineMedium => headlineLarge.copyWith(fontSize: 32);

  static TextStyle get headlineSmall => headlineLarge.copyWith(fontSize: 20);

  static TextStyle get titleLarge {
    return const TextStyle(
        fontFamily: fontFamily,
        fontVariations: [
          FontVariation("wght", 800),
        ],
        fontSize: 44);
  }

  static TextStyle get titleMedium => titleLarge.copyWith(
        fontSize: 32,
      );

  static TextStyle get titleSmall => titleLarge.copyWith(
        fontSize: 20,
      );

  static TextStyle get bodyLarge {
    return const TextStyle(
      fontFamily: fontFamily,
      fontVariations: [
        FontVariation("wght", 400),
      ],
      fontSize: 20,
    );
  }

  static TextStyle get bodyMedium => bodyLarge.copyWith(fontSize: 18);

  static TextStyle get bodySmall => bodyLarge.copyWith(fontSize: 16);

  static TextStyle get labelLarge {
    return const TextStyle(
      fontFamily: fontFamily,
      fontVariations: [
        FontVariation("wght", 400),
      ],
      fontSize: 16,
    );
  }

  static TextStyle get labelMedium => labelLarge.copyWith(fontSize: 17);

  static TextStyle get labelSmall => labelLarge.copyWith(fontSize: 15);

  static BoxDecoration cardShape(Color color, [double? radius]) =>
      BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(radius ?? 1),
          border: Border.all(
              color: color,
              width: 1,
              strokeAlign: BorderSide.strokeAlignCenter));

  static ButtonStyle get button {
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade900;
        }
        return Colors.black;
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade800;
        }
        // This will be updated to use Theme.of(context) in the refactoring step
        return Colors.green; // Placeholder, will be replaced
      }),
    );
  }
}

class PhrazyTheme {
  static ThemeData getTheme(PhrazyColors colors) {
    return ThemeData(
      iconTheme: IconThemeData(color: colors.textColor),
      shadowColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: colors.backgroundColor,
        surface: colors.backgroundColor,
        onSurface: colors.textColor,
        outline: colors.borderColor,
        surfaceContainer: colors.cardColor,
        onInverseSurface: colors.onCardColor,
        surfaceContainerLow: colors.foregroundColorLight,
        surfaceContainerLowest: colors.foregroundColor,
        surfaceBright: colors.backgroundColorLight,
        surfaceContainerHigh: colors.dialogColor,
        tertiary: colors.yesColor,
        error: colors.noColor,
        secondaryContainer: colors.iconBackgroundColor,
      ),
      useMaterial3: true,
      textTheme: TextTheme(
        displayLarge: Style.displayLarge,
        displayMedium: Style.displayMedium,
        displaySmall: Style.displaySmall,
        headlineLarge: Style.headlineLarge,
        headlineMedium: Style.headlineMedium,
        headlineSmall: Style.headlineSmall,
        titleLarge: Style.titleLarge,
        titleMedium: Style.titleMedium,
        titleSmall: Style.titleSmall,
        bodyLarge: Style.bodyLarge,
        bodyMedium: Style.bodyMedium,
        bodySmall: Style.bodySmall,
        labelLarge: Style.labelLarge,
        labelMedium: Style.labelMedium,
        labelSmall: Style.labelSmall,
      ),
    );
  }
}
