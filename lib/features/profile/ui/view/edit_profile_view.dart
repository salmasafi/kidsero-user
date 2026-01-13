import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/data/models/user_model.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import '../../../core/network/api_helper.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileView extends StatefulWidget {
  final UserModel user;

  const EditProfileView({super.key, required this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _avatarController = TextEditingController(text: widget.user.avatar ?? '');
  }

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
          title: Text(l10n.editProfile, style: TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.subHeadingSize(context))),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
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
                    label: l10n.fullName,
                    icon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  SizedBox(height: AppSizes.spacing(context) * 1.5),
                  CustomTextField(
                    label: l10n.avatarUrl,
                    icon: Icons.image_outlined,
                    controller: _avatarController,
                  ),
                  SizedBox(height: AppSizes.spacing(context) * 3),
                  CustomButton(
                    text: l10n.saveChanges,
                    gradient: AppColors.parentGradient,
                    isLoading: state is ProfileLoading,
                    onPressed: () {
                      context.read<ProfileCubit>().updateProfile(
                            _nameController.text,
                            _avatarController.text,
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
