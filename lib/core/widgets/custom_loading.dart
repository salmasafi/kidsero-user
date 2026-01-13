import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

class CustomLoading extends StatelessWidget {
  final double? size;
  final Color? color;

  const CustomLoading({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? AppSizes.spacing(context) * 2,
        height: size ?? AppSizes.spacing(context) * 2,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.parentPrimary),
          strokeWidth: 3,
        ),
      ),
    );
  }
}
