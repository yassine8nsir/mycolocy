import 'package:flutter/material.dart';

/// Single source of truth for every colour used in the app.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3068E6);
  static const Color primaryLight = Color(0xFFEEF3FD);
  static const Color accent = Color(0xFF00C896);

  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;

  static const Color textDark = Color(0xFF1E2235);
  static const Color textMedium = Color(0xFF4A4F6A);
  static const Color textLight = Color(0xFF8A90A6);

  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFA726);

  static const Color divider = Color(0xFFE8EAF0);
  static const Color shadow = Color(0x1A000000);
}
