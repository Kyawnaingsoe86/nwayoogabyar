import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 210, 105, 30),
    onPrimary: Color.fromARGB(255, 255, 255, 255),
    primaryContainer: Color.fromARGB(255, 226, 226, 226),
    onPrimaryContainer: Color.fromARGB(255, 86, 86, 86),
    secondary: Color.fromARGB(255, 255, 145, 48),
    onSecondary: Color.fromARGB(255, 255, 255, 255),
    secondaryContainer: Color.fromARGB(255, 219, 219, 219),
    onSecondaryContainer: Colors.black,
    tertiaryContainer: Color.fromARGB(255, 122, 122, 122),
    onTertiaryContainer: Color.fromARGB(255, 233, 233, 233),
    error: Color.fromARGB(255, 255, 17, 0),
    onError: Color.fromARGB(255, 218, 0, 0),
    background: Color.fromARGB(255, 255, 255, 255),
    onBackground: Color.fromARGB(255, 0, 0, 0),
    surface: Color.fromARGB(255, 255, 255, 255),
    onSurface: Color.fromARGB(255, 0, 0, 0),
    surfaceVariant: Color.fromARGB(255, 255, 255, 255),
    onSurfaceVariant: Color.fromARGB(255, 116, 116, 116),
    surfaceTint: Color.fromARGB(255, 255, 255, 255),
    scrim: Color.fromARGB(255, 255, 255, 255),
    shadow: Color.fromARGB(150, 116, 116, 116),
  ),
  fontFamily: 'Pyidaungsu',
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 210, 105, 30),
    onPrimary: Color.fromARGB(255, 235, 235, 235),
    primaryContainer: Color.fromARGB(255, 114, 114, 114),
    onPrimaryContainer: Color.fromARGB(255, 230, 230, 230),
    secondary: Color.fromARGB(255, 138, 86, 6),
    onSecondary: Color.fromARGB(255, 237, 237, 237),
    secondaryContainer: Color.fromARGB(255, 202, 202, 202),
    onSecondaryContainer: Color.fromARGB(255, 169, 14, 14),
    tertiaryContainer: Color.fromARGB(255, 117, 65, 65),
    onTertiaryContainer: Color.fromARGB(255, 233, 233, 233),
    error: Color.fromARGB(255, 255, 17, 0),
    onError: Color.fromARGB(255, 218, 0, 0),
    background: Color.fromARGB(255, 0, 0, 0),
    onBackground: Color.fromARGB(255, 240, 240, 240),
    surface: Color.fromARGB(255, 0, 0, 0),
    onSurface: Color.fromARGB(255, 255, 255, 255),
    surfaceVariant: Color.fromARGB(255, 131, 131, 131),
    onSurfaceVariant: Color.fromARGB(255, 247, 247, 247),
    scrim: Colors.white,
    shadow: Color.fromARGB(95, 255, 255, 255),
  ),
  fontFamily: 'Pyidaungsu',
);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromARGB(255, 210, 105, 30),
  onPrimary: Color.fromARGB(255, 255, 255, 255),
  primaryContainer: Color.fromARGB(255, 249, 249, 249),
  onPrimaryContainer: Color.fromARGB(255, 0, 0, 0),
  secondary: Color.fromARGB(255, 255, 145, 48),
  onSecondary: Color.fromARGB(255, 255, 255, 255),
  secondaryContainer: Color.fromARGB(255, 181, 181, 181),
  onSecondaryContainer: Colors.black,
  tertiaryContainer: Color.fromARGB(255, 122, 122, 122),
  onTertiaryContainer: Color.fromARGB(255, 233, 233, 233),
  error: Color.fromARGB(255, 255, 17, 0),
  onError: Color.fromARGB(255, 218, 0, 0),
  background: Color.fromARGB(255, 255, 255, 255),
  onBackground: Color.fromARGB(255, 0, 0, 0),
  surface: Color.fromARGB(255, 255, 255, 255),
  onSurface: Color.fromARGB(255, 0, 0, 0),
  surfaceVariant: Color.fromARGB(255, 255, 255, 255),
  onSurfaceVariant: Color.fromARGB(255, 116, 116, 116),
  scrim: Color.fromARGB(255, 255, 255, 255),
  shadow: Color.fromARGB(150, 116, 116, 116),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color.fromARGB(255, 232, 39, 39),
  onPrimary: Color.fromARGB(255, 226, 226, 226),
  primaryContainer: Color.fromARGB(255, 114, 114, 114),
  onPrimaryContainer: Color.fromARGB(255, 255, 255, 255),
  secondary: Color.fromARGB(255, 103, 103, 103),
  onSecondary: Color.fromARGB(255, 255, 255, 255),
  secondaryContainer: Color.fromARGB(255, 202, 202, 202),
  onSecondaryContainer: Color.fromARGB(255, 169, 14, 14),
  tertiaryContainer: Color.fromARGB(255, 122, 122, 122),
  onTertiaryContainer: Color.fromARGB(255, 233, 233, 233),
  error: Color.fromARGB(255, 255, 17, 0),
  onError: Color.fromARGB(255, 218, 0, 0),
  background: Color.fromARGB(255, 0, 0, 0),
  onBackground: Color.fromARGB(255, 240, 240, 240),
  surface: Color.fromARGB(255, 0, 0, 0),
  onSurface: Color.fromARGB(255, 255, 255, 255),
  surfaceVariant: Color.fromARGB(255, 131, 131, 131),
  onSurfaceVariant: Color.fromARGB(255, 247, 247, 247),
  scrim: Colors.white,
  shadow: Color.fromARGB(95, 54, 54, 54),
);
