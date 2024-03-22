import 'package:flutter/material.dart';

class DesignProvider {
  static ShapeBorder getDialogBoxShape(double radius) {
    return OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static ButtonStyle getElevationButtonShape(
      double radius, Color bgColor, Color fgColor) {
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      backgroundColor: bgColor,
      foregroundColor: fgColor,
    );
  }
}
