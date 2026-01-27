import 'package:flutter/material.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/widgets/custom_button.dart';

class CustomEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Color? iconColor;
  final VoidCallback? onAction;
  final String? actionLabel;
  final RefreshCallback? onRefresh;

  const CustomEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.iconColor,
    this.onAction,
    this.actionLabel,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Container(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.driverPrimary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 100,
                color: iconColor ?? AppColors.driverPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.onBackground.withOpacity(0.7),
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              CustomButton(onPressed: onAction!, text: actionLabel!),
            ],
          ],
        ),
      ),
    );

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.driverPrimary,
        child: content,
      );
    }

    return content;
  }
}
