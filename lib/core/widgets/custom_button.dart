import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? color;
  final bool isLoading;
  final double? height;
  final double? width;
  final double? borderRadius;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.color,
    this.isLoading = false,
    this.height,
    this.width,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 56;
    final buttonRadius = borderRadius ?? 16;
    final buttonColor = color ?? AppColors.primary;
    final buttonGradient = gradient ?? LinearGradient(
      colors: [buttonColor, buttonColor.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: width ?? double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(buttonRadius),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: textStyle ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
              ),
      ),
    );
  }
}
