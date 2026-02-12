import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A reusable gradient header widget
class GradientHeader extends StatelessWidget {
  final Widget child;
  final double? height;
  final List<Color>? gradientColors;
  final EdgeInsets? padding;
  final bool showBackButton;
  final VoidCallback? onBack;

  const GradientHeader({
    super.key,
    required this.child,
    this.height,
    this.gradientColors,
    this.padding,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              gradientColors ??
              [
                AppColors.primary,
                AppColors.secondary
              ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Back button if needed
            if (showBackButton)
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            // Main content
            Padding(padding: padding ?? const EdgeInsets.all(20), child: child),
          ],
        ),
      ),
    );
  }
}
