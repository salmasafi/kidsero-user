import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.getFontFamily(context),
            fontSize: AppSizes.smallSize(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.transparent),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: TextStyle(
              fontFamily: AppTextStyles.getFontFamily(context),
              fontSize: AppSizes.bodySize(context),
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
              border: InputBorder.none,
              hintText: label,
              hintStyle: TextStyle(
                fontFamily: AppTextStyles.getFontFamily(context),
                color: AppColors.textTertiary,
                fontSize: AppSizes.bodySize(context),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: (AppSizes.inputHeight(context) - 24) / 2,
                horizontal: AppSizes.padding(context) * 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
