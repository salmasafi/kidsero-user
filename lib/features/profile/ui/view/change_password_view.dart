import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/theme/app_sizes.dart';
import 'package:kidsero_driver/core/widgets/custom_button.dart';
import 'package:kidsero_driver/core/widgets/custom_text_field.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import 'package:kidsero_driver/core/network/api_helper.dart';
import '../../data/repositories/profile_repository.dart';
import 'package:kidsero_driver/core/widgets/custom_snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/widgets/language_toggle.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => ProfileCubit(
        ProfileRepository(context.read<ApiHelper>()),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(l10n.changePassword, style: TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.subHeadingSize(context))),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: LanguageToggle(),
            ),
          ],
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is PasswordChangeSuccess) {
              CustomSnackbar.showSuccess(context, state.message);
              context.pop();
            } else if (state is ProfileError) {
              CustomSnackbar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.padding(context)),
              child: Column(
                children: [
                  CustomTextField(
                    label: l10n.oldPassword,
                    icon: Icons.lock_outline,
                    controller: _oldPasswordController,
                    isPassword: true,
                  ),
                  SizedBox(height: AppSizes.spacing(context) * 1.5),
                  CustomTextField(
                    label: l10n.newPassword,
                    icon: Icons.lock_outline,
                    controller: _newPasswordController,
                    isPassword: true,
                  ),
                  SizedBox(height: AppSizes.spacing(context) * 3),
                  CustomButton(
                    text: l10n.changePassword,
                    gradient: AppColors.parentGradient,
                    isLoading: state is ProfileLoading,
                    onPressed: () {
                      context.read<ProfileCubit>().changePassword(
                            _oldPasswordController.text,
                            _newPasswordController.text,
                          );
                    },
                  ),
                ].animate(interval: 100.ms).fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
              ),
            );
          },
        ),
      ),
    );
  }
}
