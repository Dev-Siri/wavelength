import "package:flutter/material.dart";

class AmplColors {
  static const background = Colors.black;
  static const foreground = Colors.white;

  static const interaction = Colors.blue;
  static const selection = Colors.blue;
}

class AmplTypography {
  static const fontFamily = "Geist";
  static const fallback = ["AppleColorEmoji", "NotoColorEmoji"];
}

final androidTheme = ThemeData(
  colorScheme: const ColorScheme.dark().copyWith(
    primary: AmplColors.foreground,
    surface: AmplColors.background,
  ),
  scaffoldBackgroundColor: AmplColors.background,
  appBarTheme: const AppBarTheme(backgroundColor: AmplColors.background),
  fontFamily: AmplTypography.fontFamily,
  fontFamilyFallback: AmplTypography.fallback,
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: Colors.blue.withAlpha(102),
    selectionHandleColor: Colors.blue,
  ),
);

// const iosTheme = CupertinoThemeData(
//   brightness: Brightness.dark,
//   primaryColor: AmplColors.foreground,
//   barBackgroundColor: AmplColors.background,
//   scaffoldBackgroundColor: AmplColors.background,
//   textTheme: CupertinoTextThemeData(
//     textStyle: TextStyle(
//       fontFamily: AmplTypography.fontFamily,
//       color: AmplColors.foreground,
//     ),
//   ),
// );
