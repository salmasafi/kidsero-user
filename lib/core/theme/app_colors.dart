import 'package:flutter/material.dart';

class AppColors {
  static const Color parentPrimary = Color(0xFF8B5CF6); // Purple
  static const Color driverPrimary = Color(0xFF0D9488); // Teal
  
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color inputBackground = Color(0xFFF3F4F6);
  static const Color error = Color(0xFFEF4444);
  
  static const LinearGradient parentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient driverGradient = LinearGradient(
    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
