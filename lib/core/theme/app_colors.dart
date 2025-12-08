import 'package:flutter/material.dart';

/// Application color palette - Clean neutral theme
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF2D3436);
  static const Color primaryLight = Color(0xFF636E72);
  static const Color primaryDark = Color(0xFF1E272E);

  // Accent colors
  static const Color accent = Color(0xFF00B894);
  static const Color accentLight = Color(0xFF55EFC4);
  static const Color accentDark = Color(0xFF00896B);

  // Background colors - Light theme
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background colors - Dark theme
  static const Color backgroundDark = Color(0xFF1E272E);
  static const Color surfaceDark = Color(0xFF2D3436);
  static const Color cardDark = Color(0xFF353B48);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFB2BEC3);

  // Kanban column colors
  static const Color todoColumn = Color(0xFFE17055);
  static const Color inProgressColumn = Color(0xFFFDCB6E);
  static const Color doneColumn = Color(0xFF00B894);

  // Status colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color info = Color(0xFF0984E3);

  // Border colors
  static const Color borderLight = Color(0xFFDFE6E9);
  static const Color borderDark = Color(0xFF4A5568);
}

