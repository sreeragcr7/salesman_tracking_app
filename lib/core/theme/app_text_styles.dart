import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // Large headings
  static const TextStyle headlineLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);

  static const TextStyle headlineMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

  // Section / screen titles
  static const TextStyle titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.w600);

  static const TextStyle titleMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  // Normal content
  static const TextStyle bodyLarge = TextStyle(fontSize: 16);

  static const TextStyle bodyMedium = TextStyle(fontSize: 14);

  static const TextStyle bodySmall = TextStyle(fontSize: 12);

  // Labels / buttons
  static const TextStyle labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  static const TextStyle labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
}
