import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A reusable stat card widget for displaying statistics
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighlighted
        ? AppColors.success // Teal for highlighted
        : backgroundColor ?? Colors.white.withOpacity(0.15);
    final txtColor = textColor ?? Colors.white;
    final icnColor = iconColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: icnColor, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: txtColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: txtColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
