import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_sizes.dart';
import '../network/exceptions.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final dynamic error;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this is an authentication error
    final isAuthError = error is AuthenticationException;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(),
              color: _getErrorColor(),
              size: AppSizes.width(context) * 0.2,
            ),
            SizedBox(height: AppSizes.spacing(context)),
            Text(
              message,
              style: AppTextStyles.subHeading(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacing(context) * 2),
            if (isAuthError)
              SizedBox(
                width: AppSizes.width(context) * 0.5,
                child: CustomButton(
                  text: 'Login',
                  gradient: AppColors.parentGradient,
                  onPressed: () {
                    // Navigate to login screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              )
            else if (onRetry != null)
              SizedBox(
                width: AppSizes.width(context) * 0.5,
                child: CustomButton(
                  text: 'Retry',
                  gradient: AppColors.parentGradient,
                  onPressed: onRetry!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    if (error is NetworkException) {
      return Icons.wifi_off;
    } else if (error is AuthenticationException) {
      return Icons.lock_outline;
    } else if (error is ServerException) {
      return Icons.cloud_off;
    } else if (error is NotFoundException) {
      return Icons.search_off;
    } else {
      return Icons.error_outline;
    }
  }

  Color _getErrorColor() {
    if (error is AuthenticationException) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
