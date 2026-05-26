import 'package:flutter/material.dart';

class AppColors {
  // Core palette
  static const background = Color(0xFF0F1117);
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF8B85FF);
  static const primaryDark = Color(0xFF5046E5);
  static const surface = Color(0xFF1A1D27);
  static const surfaceElevated = Color(0xFF232735);
  static const surfaceGlass = Color(0xFF1A1D27);
  static const textPrimary = Color(0xFFE8E9ED);
  static const textSecondary = Color(0xFFB0B3C0);
  static const textMuted = Color(0xFF9499A8);
  static const onlineOrSuccess = Color(0xFF00D9A6);
  static const errorOrDanger = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFFB347);
  static const borderOrDivider = Color(0xFF2D3142);
  static const borderLight = Color(0xFF3A3F55);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceElevated],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glassmorphism
  static const glassBackground = Color(0x1A1A1D27);
  static const glassBorder = Color(0x26FFFFFF);
}