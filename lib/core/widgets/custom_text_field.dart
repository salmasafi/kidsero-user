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
            color: Color(0xFF1F2937),
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: showError ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
              width: showError ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1F2937),
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: const Icon(
                        Icons.visibility_off,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      onPressed: () {
                        // Toggle password visibility logic should be handled by parent
                      },
                    )
                  : null,
              hintText: hintText ?? label,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
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
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ),
      ],
    );
  }
}
