import 'package:flutter/material.dart';

class AppTheme {
  // Core colors from the glassmorphism design
  static const Color primaryOrange = Color(0xFFF48C25);
  static const Color primaryDark = Color(0xFF1C1C1C);
  static const Color white = Color(0xFFFFFFFF);
  
  // Background gradient colors
  static const Color bgLightAsh = Color(0xFFEFEFEF);
  
  // Glass properties
  static Color glassBackground = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.3);
  static Color glassShadow = Colors.black.withValues(alpha: 0.05);
}
