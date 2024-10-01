import 'package:flutter/material.dart';

class Style {
  static const String title = 'Phrasewalk';
  static const String subtitle = 'Assemble the words into phrases!';
  static const String howToPlay =
      "Try to figure out which song the shown lyrics are from.\n"
      "Lyric excerpts might not be in order!\n"
      "You have 5 guesses.";

  static const fontFamily = 'Fraunces';

  static TextStyle get displayLarge {
    return const TextStyle(
      fontFamily: "$fontFamily-Italic",
      fontVariations: [
        FontVariation("wght", 400),
        FontVariation("wonk", 1),
        FontVariation("soft", 100),
      ],
    );
  }

  static TextStyle get displayMedium => displayLarge;

  static TextStyle get displaySmall => displayLarge;

  static TextStyle get headlineLarge {
    return const TextStyle(
      fontFamily: "$fontFamily-Italic",
      fontVariations: [
        FontVariation("wght", 400),
        FontVariation("wonk", 1),
        FontVariation("soft", 100),
      ],
    );
  }

  static TextStyle get headlineMedium => headlineLarge;

  static TextStyle get headlineSmall => headlineLarge;

  static TextStyle get titleLarge {
    return const TextStyle(
        fontFamily: "$fontFamily-Italic",
        fontVariations: [
          FontVariation("wght", 400),
          FontVariation("wonk", 1),
          FontVariation("soft", 100),
        ],
        fontSize: 40);
  }

  static TextStyle get titleMedium => titleLarge.copyWith(
        fontSize: 24,
        // letterSpacing: 2.0,
      );

  static TextStyle get titleSmall => titleLarge.copyWith(
        fontSize: 14,
        // letterSpacing: 2.0,
      );

  static TextStyle get bodyLarge {
    return const TextStyle(
      fontFamily: fontFamily,
      fontVariations: [
        FontVariation("wght", 400),
        FontVariation("wonk", 1),
        FontVariation("soft", 100),
      ],
    );
  }

  static TextStyle get bodyMedium => bodyLarge;

  static TextStyle get bodySmall => bodyLarge;

  static TextStyle get labelLarge {
    return const TextStyle(
      fontFamily: fontFamily,
      fontVariations: [
        FontVariation("wght", 400),
        FontVariation("wonk", 1),
        FontVariation("soft", 100),
      ],
    );
  }

  static TextStyle get labelMedium => labelLarge;

  static TextStyle get labelSmall => labelLarge;

  static RoundedRectangleBorder cardShape(Color color, [double? radius]) =>
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 1),
          side: BorderSide(
              color: color,
              width: 1,
              strokeAlign: BorderSide.strokeAlignCenter));
}

class GuesserThemeData {
  static ThemeData get instance => ThemeData(
        shadowColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink, brightness: Brightness.dark),
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
