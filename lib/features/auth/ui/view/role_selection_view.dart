import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/enums.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.padding(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.welcome,
                style: AppTextStyles.heading(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.spacing(context)),
              Text(
                l10n.selectRole,
                style: AppTextStyles.subHeading(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.spacing(context) * 3),
              CustomButton(
                text: l10n.imParent,
                gradient: AppColors.parentGradient,
                onPressed: () => context.push(Routes.login, extra: UserRole.parent),
              ),
              SizedBox(height: AppSizes.spacing(context) * 1.5),
              CustomButton(
                text: l10n.imDriver,
                gradient: AppColors.driverGradient,
                onPressed: () => context.push(Routes.login, extra: UserRole.driver),
              ),
            ].animate(interval: 100.ms).fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
          ),
        ),
      ),
    );
  }
}
