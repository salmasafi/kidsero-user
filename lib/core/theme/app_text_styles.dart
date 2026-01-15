import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

class AppTextStyles {
  static const String _fontFamily = 'Cairo';

  static String getFontFamily(BuildContext context) {
    return _fontFamily;
  }

  static TextStyle heading(BuildContext context) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppSizes.headingSize(context),
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle subHeading(BuildContext context) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppSizes.subHeadingSize(context),
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static TextStyle body(BuildContext context) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppSizes.bodySize(context),
    color: AppColors.textPrimary,
  );
  
  static TextStyle button(BuildContext context) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppSizes.bodySize(context) * 1.1,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
