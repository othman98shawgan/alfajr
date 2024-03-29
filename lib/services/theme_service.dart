import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../resources/colors.dart';
import 'store_manager.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData? _themeData;
  ThemeData? getTheme() => _themeData;

  ThemeMode? _themeMode;
  ThemeMode? get themeMode => _themeMode;

  String? _backgroundImage;
  String? get backgroundImage => _backgroundImage;

  ThemeNotifier(ThemeMode themeMode) {
    if (themeMode == ThemeMode.light) {
      _themeData = lightTheme;
      _themeMode = ThemeMode.light;
      _backgroundImage = 'images/bgGreen.png';
    } else {
      if (kDebugMode) {
        print('setting dark theme');
      }
      _themeData = darkTheme;
      _themeMode = ThemeMode.dark;
      _backgroundImage = 'images/bg.png';
    }
    notifyListeners();
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    _themeMode = ThemeMode.dark;
    _backgroundImage = 'images/bg.png';
    StorageManager.saveData('themeMode', 'dark');
    StorageManager.saveData('isDark', true);
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    _themeMode = ThemeMode.light;
    _backgroundImage = 'images/bgGreen.png';
    StorageManager.saveData('themeMode', 'light');
    StorageManager.saveData('isDark', false);
    notifyListeners();
  }

  //=============================================================================
  // Themes
  //=============================================================================

  //*** Dark Theme ***/
  final darkTheme = ThemeData(
    fontFamily: 'Tajawal',
    appBarTheme: const AppBarTheme(backgroundColor: appBarColor, foregroundColor: Colors.white),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: darkThemeSwatch).copyWith(
      brightness: Brightness.dark,
    ),
    toggleButtonsTheme: const ToggleButtonsThemeData(
      selectedColor: Colors.white,
    ),
  );

  //*** Light Theme ***/
  final lightTheme = ThemeData(
    fontFamily: 'Tajawal',
    appBarTheme: AppBarTheme(backgroundColor: color5, foregroundColor: colorTextLight),
    brightness: Brightness.light,
    drawerTheme: const DrawerThemeData(
      backgroundColor: color3,
    ),
    scaffoldBackgroundColor: color1,
    dialogBackgroundColor: color1,
    dividerColor: Colors.black26,
    focusColor: lightThemeSwatch,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(),
      bodyMedium: TextStyle(),
      bodySmall: TextStyle(),
    ).apply(
      bodyColor: colorTextLight,
      displayColor: colorTextLight,
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        iconColor: MaterialStatePropertyAll(Colors.white),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: greenMaterialColor).copyWith(),
  );
}
