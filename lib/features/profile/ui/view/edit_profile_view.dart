import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/widgets/custom_button.dart';
import 'package:kidsero_driver/features/auth/data/models/user_model.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import 'package:kidsero_driver/core/widgets/custom_snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/image_viewer.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';

class EditProfileView extends StatefulWidget {
  final UserModel user;

  const EditProfileView({super.key, required this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _avatarController;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _avatarController = TextEditingController(text: widget.user.avatar ?? '');
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to pick image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => ProfileCubit(ApiHelper()),
      child: Scaffold(
        backgroundColor: AppColors.background,
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
              child: Column(
                children: [
                  // Header Section
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.parentGradient,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(AppSizes.radiusExtraLarge),
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 40),
                                Text(
                                  l10n.editProfile,
                                  style: AppTextStyles.heading(
                                    context,
                                  ).copyWith(color: Colors.white),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => context.pop(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Avatar
                      Positioned(
                        bottom: -60,
                        child: GestureDetector(
                          onTap: () {
                            if (_imageFile != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImageViewer(
                                    imageUrl: _imageFile!.path,
                                    isLocalFile: true,
                                    heroTag: 'edit_profile_avatar',
                                  ),
                                ),
                              );
                            } else if (_avatarController.text.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImageViewer(
                                    imageUrl: ApiEndpoints.getImageUrl(
                                      _avatarController.text,
                                    ),
                                    heroTag: 'edit_profile_avatar',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Hero(
                            tag: 'edit_profile_avatar',
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: AppSizes.radiusSmall,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 70,
                                    backgroundColor: AppColors.lightGrey,
                                    backgroundImage: const AssetImage(
                                      'assets/images/parent_default.png',
                                    ),
                                    // _imageFile != null
                                    //     ? FileImage(File(_imageFile!.path))
                                    //     : (_avatarController.text.isNotEmpty
                                    //               ? NetworkImage(
                                    //                   ApiEndpoints.getImageUrl(
                                    //                     _avatarController.text,
                                    //                   ),
                                    //                 )
                                    //               : const AssetImage(
                                    //                   'assets/images/parent_default.png',
                                    //                 ))
                                    //           as ImageProvider,
                                    onBackgroundImageError: (e, s) {},
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.designPurple,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  // Form Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusExtraLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildLabeledInput(
                            l10n.fullName,
                            Icons.person_outline,
                            _nameController,
                            context,
                          ),
                          const SizedBox(height: 20),
                          _buildLabeledInput(
                            l10n.avatarUrlOptional,
                            Icons.camera_alt_outlined,
                            _avatarController,
                            context,
                          ),
                          const SizedBox(height: 25),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 15),
                          Text(
                            l10n.readOnlyFields,
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: AppSizes.smallSize(context),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildReadOnlyField(
                            l10n.phone,
                            widget.user.phone,
                            context,
                          ),
                          const SizedBox(height: 12),
                          _buildReadOnlyField(
                            l10n.role,
                            widget.user.role == 'parent'
                                ? l10n.imParent
                                : (widget.user.role ?? ''),
                            context,
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                            text: l10n.saveChanges,
                            gradient: AppColors.parentGradient,
                            isLoading: state is ProfileLoading,
                            onPressed: () {
                              context.read<ProfileCubit>().updateProfile(
                                name: _nameController.text,
                                imagePath: _imageFile?.path,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ].animate(interval: 50.ms).fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabeledInput(
    String label,
    IconData icon,
    TextEditingController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.smallSize(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.bodySize(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: AppSizes.smallSize(context),
            ),
          ),
        ],
      ),
    );
  }
}
