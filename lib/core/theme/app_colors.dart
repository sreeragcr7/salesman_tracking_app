import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color.fromARGB(255, 81, 101, 211);
  static const Color primaryDark = Color(0xFF9FA8DA);

  // Card
  static const Color lightCard = Color(0xFFF1F3F8);
  static const Color darkCard = Color(0xFF24272F);

  // Light theme
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1A1B20);
  static const Color lightSecondaryText = Color(0xFF61646B);
  static const Color lightBorder = Color(0xFFD9DCE3);

  // Dark theme
  static const Color darkBackground = Color(0xFF121318);
  static const Color darkSurface = Color(0xFF1B1D23);
  static const Color darkText = Color(0xFFF1F1F3);
  static const Color darkSecondaryText = Color(0xFFB8BAC2);
  static const Color darkBorder = Color(0xFF3A3D46);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFEF8C00);
  static const Color error = Color(0xFFD32F2F);
}
