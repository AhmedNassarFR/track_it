import 'package:flutter/material.dart';

abstract class AppColors {
  // Original palette
  static const purple = Color(0xff543D7B);
  static const lightPurple = Color(0xff6D5593);
  static const blue = Color(0xff0C134F);
  static const lightBlue = Color(0xff1D267D);
  static const white = Colors.white;
  static const black = Colors.black;
  static const darkerGrey = Color(0xff0D0D0D);
  static const darkGrey = Color(0xff1A1A2E);
  static const lightGrey = Color(0xff2A2A3E);

  // Accent gradient colors
  static const accentCyan = Color(0xff00D4FF);
  static const accentPurple = Color(0xff7B2FFF);
  static const accentPink = Color(0xffFF2D87);

  // Glass surface colors
  static Color glassFill = Colors.white.withOpacity(0.08);
  static Color glassBorder = Colors.white.withOpacity(0.15);
  static Color glassHighlight = Colors.white.withOpacity(0.05);

  // Text colors
  static Color textSecondary = Colors.white.withOpacity(0.60);
  static Color textTertiary = Colors.white.withOpacity(0.35);

  // Gradient presets
  static const accentGradient = LinearGradient(
    colors: [accentCyan, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradientVertical = LinearGradient(
    colors: [accentCyan, accentPurple],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const warmGradient = LinearGradient(
    colors: [accentPink, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}