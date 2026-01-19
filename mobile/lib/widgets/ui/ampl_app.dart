import "package:flutter/material.dart";
import "package:wavelength/widgets/ui/ampl_theme.dart";

/// AmpApp initializes a platform-specific MaterialApp or CupertinoApp with the Wavelength ThemeData.
/// Requires a [routerConfig] as Wavelength uses gorouter instead of the default.
class AmplApp extends StatelessWidget {
  /// {@macro flutter.widgets.widgetsApp.title}
  final String? title;

  /// {@macro flutter.widgets.widgetsApp.routerConfig}
  final RouterConfig<Object>? routerConfig;

  /// {@macro flutter.widgets.widgetsApp.themeMode}
  final ThemeMode themeMode;

  const AmplApp.router({
    super.key,
    this.title = "Wavelength",
    this.routerConfig,
    this.themeMode = ThemeMode.dark,
  });

  @override
  Widget build(BuildContext context) {
    // if (Platform.isIOS) {
    //   return CupertinoApp.router(
    //     title: title,
    //     routerConfig: routerConfig,
    //     theme: iosTheme,
    //   );
    // }

    return MaterialApp.router(
      title: title,
      routerConfig: routerConfig,
      themeMode: themeMode,
      theme: androidTheme,
    );
  }
}
