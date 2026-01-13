import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import 'edit_profile_view.dart';
import 'change_password_view.dart';
import '../../../core/network/api_helper.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../core/widgets/custom_error_widget.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => ProfileCubit(
        ProfileRepository(context.read<ApiHelper>()),
      )..getProfile(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.profile, style: TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.subHeadingSize(context))),
          centerTitle: true,
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const CustomLoading();
            } else if (state is ProfileLoaded) {
              final user = state.profile;
              return SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.padding(context)),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: AppSizes.width(context) * 0.15,
                      backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                      child: user.avatar == null ? Icon(Icons.person, size: AppSizes.width(context) * 0.15) : null,
                    ),
                    SizedBox(height: AppSizes.spacing(context)),
                    Text(user.name, style: AppTextStyles.heading(context).copyWith(fontSize: AppSizes.headingSize(context) * 0.8)),
                    Text(user.phone, style: AppTextStyles.subHeading(context)),
                    SizedBox(height: AppSizes.spacing(context) * 2),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.person_outline,
                      title: l10n.editProfile,
                      onTap: () => context.push(Routes.editProfile, extra: user).then((_) => context.read<ProfileCubit>().getProfile()),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.lock_outline,
                      title: l10n.changePassword,
                      onTap: () => context.push(Routes.changePassword),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.logout,
                      title: l10n.logout,
                      textColor: AppColors.error,
                      onTap: () {
                        context.go(Routes.roleSelection);
                      },
                    ),
                  ].animate(interval: 100.ms).fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
                ),
              );
            } else if (state is ProfileError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () => context.read<ProfileCubit>().getProfile(),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacing(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppColors.textPrimary),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.bodySize(context),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: AppSizes.spacing(context)),
        onTap: onTap,
      ),
    );
  }
}
