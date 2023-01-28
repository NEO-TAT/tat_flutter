import 'package:flutter/material.dart';

import 'color_schemes.g.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'TATFont',
    colorScheme: lightColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightColorScheme.background,
      selectedItemColor: lightColorScheme.tertiary,
      selectedIconTheme: IconThemeData(color: lightColorScheme.tertiary),
      unselectedItemColor: lightColorScheme.onBackground,
      unselectedIconTheme: IconThemeData(color: lightColorScheme.onBackground),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: lightColorScheme.tertiaryContainer,
      unselectedLabelColor: lightColorScheme.onPrimary,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'TATFont',
    colorScheme: darkColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.primaryContainer,
      foregroundColor: darkColorScheme.onPrimaryContainer,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkColorScheme.background,
      selectedItemColor: darkColorScheme.tertiary,
      selectedIconTheme: IconThemeData(color: darkColorScheme.tertiary),
      unselectedItemColor: darkColorScheme.onBackground,
      unselectedIconTheme: IconThemeData(color: darkColorScheme.onBackground),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: darkColorScheme.tertiary,
      unselectedLabelColor: darkColorScheme.onPrimaryContainer,
    ),
  );
}
