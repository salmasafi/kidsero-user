import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool showError;
  final String? errorMessage;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.validator,
    this.showError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: showError ? AppColors.error : AppColors.border,
              width: showError ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: const Icon(
                        Icons.visibility_off,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        // Toggle password visibility logic should be handled by parent
                      },
                    )
                  : null,
              hintText: hintText ?? label,
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontFamily: 'Cairo',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
        if (showError && errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ),
      ],
    );
  }
}
