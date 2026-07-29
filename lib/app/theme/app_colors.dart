import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Palette
  static const Color primary = Color(0FF4F46E5); // Indigo 600
  static const Color primaryHover = Color(0FF4338CA); // Indigo 700
  static const Color primaryFocused = Color(0FF3730A3);
  static const Color primaryLight = Color(0FFEEF2FF); // Indigo 50
  static const Color primaryDark = Color(0FF312E81); // Indigo 900

  // Secondary & Accent
  static const Color secondary = Color(0FF0EA5E9); // Sky 500
  static const Color accent = Color(0FF8B5CF6); // Violet 500
  static const Color gradientStart = Color(0FF4F46E5);
  static const Color gradientEnd = Color(0FF7C3AED);

  // Background & Surfaces (Light)
  static const Color backgroundLight = Color(0FFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0FFFFFF);
  static const Color cardLight = Color(0FFFFFF);
  static const Color borderLight = Color(0FFE2E8F0); // Slate 200
  static const Color dividerLight = Color(0FFF1F5F9); // Slate 100

  // Text Colors (Light)
  static const Color textPrimaryLight = Color(0FF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0FF475569); // Slate 600
  static const Color textMutedLight = Color(0FF94A3B8); // Slate 400
  static const Color textPlaceholderLight = Color(0FFCBD5E1); // Slate 300

  // Background & Surfaces (Dark)
  static const Color backgroundDark = Color(0FF0F172A); // Slate 900
  static const Color surfaceDark = Color(0FF1E293B); // Slate 800
  static const Color cardDark = Color(0FF1E293B);
  static const Color borderDark = Color(0FF334155); // Slate 700
  static const Color dividerDark = Color(0FF1E293B);

  // Text Colors (Dark)
  static const Color textPrimaryDark = Color(0FFF8FAFC);
  static const Color textSecondaryDark = Color(0FF94A3B8);
  static const Color textMutedDark = Color(0FF64748B);
  static const Color textPlaceholderDark = Color(0FF475569);

  // Feedback Colors
  static const Color success = Color(0FF10B981); // Emerald 500
  static const Color successLight = Color(0FFECFDF5);
  static const Color error = Color(0FFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0FFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color info = Color(0FF3B82F6); // Blue 500

  // Social Colors
  static const Color googleRed = Color(0FFEA4335);
  static const Color googleBorder = Color(0FFDADCE0);

  // Overlay & Shadows
  static const Color overlayDark = Color(0x66000000);
  static const Color shadowColor = Color(0x0F0F172A);
}
