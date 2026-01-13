import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_sizes.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: AppSizes.width(context) * 0.2,
            ),
            SizedBox(height: AppSizes.spacing(context)),
            Text(
              message,
              style: AppTextStyles.subHeading(context),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSizes.spacing(context) * 2),
              SizedBox(
                width: AppSizes.width(context) * 0.5,
                child: CustomButton(
                  text: 'Retry', // Should be localized if needed, but keeping it simple for now
                  gradient: AppColors.parentGradient,
                  onPressed: onRetry!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
