import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF0D9488); // Teal
  static const Color secondary = Color(0xFFFA8231); // Orange
  static const Color accent = Color(0xFFFA8231); // Orange

  // Role Specific
  static const Color parentPrimary = Color(0xFF0D9488);
  static const Color driverPrimary = Color(0xFF0D9488);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color background = Color(
    0xFFF8F9FA,
  ); // Light off-white background
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937); // Dark grey
  static const Color textSecondary = Color(0xFF6B7280); // Medium grey
  static const Color textTertiary = Color(0xFF9CA3AF); // Light grey
  static const Color border = Color(0xFFE5E7EB);
  static const Color inputBackground = Color(
    0xFFF3F4F6,
  ); // Light grey input background

  // Shared colors (matching previous usage)
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onSurface = Color(0xFF1F2937);
  static const Color onBackground = Color(0xFF1F2937);
  static const Color onError = Colors.white;

  // Design Specific
  static const Color designPurple = Color(0xFF8B5CF6);
  static const Color designOrange = Color(0xFFFA8231);
  static const Color lightGrey = Color(0xFFF8F9FA);
  static const Color gold = Color(0xFFF7B731);
  static const Color lightOrange = Color(0xFFFFF4E8);
  static const Color designYellow = Color(0xFFFFEAA7);
  static const Color deepOrange = Color(0xFFF39C12);
  static const Color orangeAccent = Color(0xFFE67E22);

  // Gradients
  static const LinearGradient parentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient driverGradient = LinearGradient(
    colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
