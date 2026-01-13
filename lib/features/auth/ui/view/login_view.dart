import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/theme/app_text_styles.dart';
import 'package:kidsero_driver/core/theme/app_sizes.dart';
import 'package:kidsero_driver/core/widgets/custom_button.dart';
import 'package:kidsero_driver/core/widgets/custom_text_field.dart';
import 'package:kidsero_driver/core/utils/enums.dart';
import '../../logic/cubit/auth_cubit.dart';
import '../../logic/cubit/auth_state.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:kidsero_driver/core/network/api_helper.dart';
import 'package:kidsero_driver/core/widgets/custom_snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/core/routing/routes.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kidsero_driver/l10n/app_localizations.dart';

class LoginView extends StatefulWidget {
  final UserRole role;

  const LoginView({super.key, required this.role});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isParent = widget.role == UserRole.parent;
    final primaryGradient = isParent ? AppColors.parentGradient : AppColors.driverGradient;
    final roleName = isParent ? l10n.parentLogin : l10n.driverLogin;

    return BlocProvider(
      create: (context) => AuthCubit(
        AuthRepository(context.read<ApiHelper>()),
        context.read<ApiHelper>(),
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
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              CustomSnackbar.showSuccess(context, l10n.loginSuccessful);
              context.go(Routes.home);
            } else if (state is AuthError) {
              CustomSnackbar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.padding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleName,
                    style: AppTextStyles.heading(context),
                  ),
                  SizedBox(height: AppSizes.spacing(context) * 0.5),
                  Text(
                    l10n.enterCredentials,
                    style: AppTextStyles.subHeading(context),
                  ),
                  SizedBox(height: AppSizes.spacing(context) * 3),
                  CustomTextField(
                    label: l10n.phoneNumber,
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: AppSizes.spacing(context) * 1.5),
                  CustomTextField(
                    label: l10n.password,
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    isPassword: true,
                  ),
                  SizedBox(height: AppSizes.spacing(context) * 3),
                  CustomButton(
                    text: l10n.login,
                    gradient: primaryGradient,
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (isParent) {
                        context.read<AuthCubit>().parentLogin(
                              _phoneController.text,
                              _passwordController.text,
                            );
                      } else {
                        context.read<AuthCubit>().driverLogin(
                              _phoneController.text,
                              _passwordController.text,
                            );
                      }
                    },
                  ),
                ].animate(interval: 100.ms).fade(duration: 500.ms).slideX(begin: 0.1, end: 0),
              ),
            );
          },
        ),
      ),
    );
  }
}
