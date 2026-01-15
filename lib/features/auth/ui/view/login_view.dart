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
import 'package:kidsero_driver/core/widgets/language_toggle.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isParent = widget.role == UserRole.parent;
    final primaryColor = isParent ? const Color(0xFF8B5CF6) : const Color(0xFF0D9488);
    final roleName = isParent ? l10n.parentLogin : l10n.driverLogin;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
            ),
            onPressed: () => context.pop(),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: LanguageToggle(),
            ),
          ],
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
              padding: EdgeInsets.symmetric(horizontal: AppSizes.padding(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: AppSizes.spacing(context)),
                    // User Icon
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 60),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    
                    SizedBox(height: AppSizes.spacing(context) * 1.5),
                    
                    Text(
                      roleName,
                      style: AppTextStyles.heading(context).copyWith(fontSize: 28),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    
                    Text(
                      l10n.trackSafely,
                      style: AppTextStyles.subHeading(context),
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
                    
                    SizedBox(height: AppSizes.spacing(context) * 3),

                    SizedBox(
                      width: double.infinity,
                      child: CustomTextField(
                        label: l10n.phoneNumber,
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
                    
                    SizedBox(height: AppSizes.spacing(context) * 1.5),
                    
                    SizedBox(
                      width: double.infinity,
                      child: CustomTextField(
                        label: l10n.password,
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                      ),
                    ).animate().fade(delay: 500.ms).slideX(begin: 0.1, end: 0),
                    
                    Align(
                      alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          l10n.forgotPassword,
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ).animate().fade(delay: 600.ms),
                    
                    SizedBox(height: AppSizes.spacing(context) * 2),
                    
                    CustomButton(
                      text: l10n.login,
                      gradient: isParent ? AppColors.parentGradient : AppColors.driverGradient,
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
                    ).animate().fade(delay: 700.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                    
                    SizedBox(height: AppSizes.spacing(context) * 1.5),
                    
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.body(context).copyWith(fontSize: 13),
                        children: [
                          TextSpan(text: '${l10n.dontHaveAccount} ', style: const TextStyle(color: Colors.grey)),
                          TextSpan(
                            text: l10n.contactAdmin,
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 800.ms),
                    
                    SizedBox(height: AppSizes.spacing(context) * 2),
                    
                    const Text('🚌', style: TextStyle(fontSize: 40)).animate().fade(delay: 900.ms).slideY(begin: 0.5, end: 0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
