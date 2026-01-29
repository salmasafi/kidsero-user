import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/theme/app_text_styles.dart';
import 'package:kidsero_driver/core/theme/app_sizes.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import 'package:kidsero_driver/core/widgets/custom_loading.dart';
import 'package:kidsero_driver/core/widgets/custom_error_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/core/routing/routes.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/image_viewer.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import '../widgets/children_list_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => ProfileCubit(ApiHelper())..getProfile(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const CustomLoading();
            } else if (state is ProfileLoaded) {
              final user = state.profile;
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
                              bottom: Radius.circular(
                                AppSizes.radiusExtraLarge,
                              ),
                            ),
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Container(
                                  //   padding: const EdgeInsets.all(8),
                                  //   decoration: const BoxDecoration(
                                  //     color: Colors.white,
                                  //     shape: BoxShape.circle,
                                  //   ),
                                  //   child: InkWell(
                                  //     onTap: () => showLanguageDialog(context),
                                  //     child: Text(
                                  //       l10n.localeName.toUpperCase(),
                                  //       style: TextStyle(
                                  //         color: AppColors.designPurple,
                                  //         fontWeight: FontWeight.bold,
                                  //         fontSize: AppSizes.smallSize(context),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.translate,
                                        color: AppColors.background,
                                        size: AppSizes.bodySize(context) * 1.5,
                                      ),
                                      onPressed: () {
                                        showLanguageDialog(context);
                                      },
                                    ),
                                  ),
                                  Text(
                                    l10n.profile,
                                    style: AppTextStyles.heading(
                                      context,
                                    ).copyWith(color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: AppSizes.bodySize(context) * 1.5,
                                    ),
                                    onPressed: () => context.pop(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Avatar
                        Positioned(
                          bottom: -50,
                          child: GestureDetector(
                            onTap: () {
                              if (user.avatar != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImageViewer(
                                      imageUrl: ApiEndpoints.getImageUrl(
                                        user.avatar!,
                                      ),
                                      heroTag: 'profile_avatar',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Hero(
                              tag: 'profile_avatar',
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
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppColors.lightGrey,
                                  backgroundImage: const AssetImage(
                                    'assets/images/parent_default.png',
                                  ),
                                  // user.avatar != null &&
                                  //         user.avatar!.isNotEmpty
                                  //     ? NetworkImage(
                                  //         ApiEndpoints.getImageUrl(
                                  //           user.avatar!,
                                  //         ),
                                  //       )
                                  //     : const AssetImage(
                                  //             'assets/images/parent_default.png',
                                  //           )
                                  //           as ImageProvider,
                                  onBackgroundImageError: (exception, stackTrace) {
                                    // Fallback handled by foreground image or just left as is if backgroundImage fails
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    // User Info Header
                    Text(user.name, style: AppTextStyles.heading(context)),

                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 12,
                    //     vertical: 4,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: AppColors.designPurple.withOpacity(0.1),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Text(
                    //     user.role == 'parent'
                    //         ? l10n.imParent
                    //         : (user.role ?? ''),
                    //     style: TextStyle(
                    //       color: AppColors.designPurple,
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: AppSizes.smallSize(context),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 20),

                    // Info Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            Icons.phone_outlined,
                            user.phone,
                            AppColors.gold,
                          ),
                          _buildInfoRow(
                            context,
                            Icons.location_on_outlined,
                            user.address ?? l10n.noAddressProvided,
                            AppColors.gold,
                          ),
                          // _buildInfoRow(
                          //   context,
                          //   Icons.group_outlined,
                          //   '${user.children?.length ?? 0} ${l10n.children}',
                          //   AppColors.gold,
                          // ),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 20),

                    // // Language Selector
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 20,
                    //   ),
                    //   child: InkWell(
                    //     onTap: () {
                    //       showLanguageDialog(context);
                    //     },
                    //     borderRadius: BorderRadius.circular(20),
                    //     child: Container(
                    //       padding: const EdgeInsets.all(12),
                    //       decoration: BoxDecoration(
                    //         color: AppColors.lightGrey.withOpacity(0.5),
                    //         borderRadius: BorderRadius.circular(20),
                    //       ),
                    //       child: Row(
                    //         mainAxisAlignment:
                    //             MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Container(
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 10,
                    //               vertical: 4,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               color: const Color(
                    //                 0xFFFFEAA7,
                    //               ), // Light yellow for EN tag
                    //               borderRadius: BorderRadius.circular(
                    //                 10,
                    //               ),
                    //             ),
                    //             child: Text(
                    //               l10n.localeName.toUpperCase(),
                    //               style: TextStyle(
                    //                 color: AppColors.orangeAccent,
                    //                 fontWeight: FontWeight.bold,
                    //                 fontSize: AppSizes.smallSize(
                    //                   context,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //           Column(
                    //             crossAxisAlignment:
                    //                 CrossAxisAlignment.end,
                    //             children: [
                    //               Text(
                    //                 l10n.language,
                    //                 style: const TextStyle(
                    //                   fontWeight: FontWeight.bold,
                    //                   fontSize: 14,
                    //                 ),
                    //               ),
                    //               Text(
                    //                 l10n.localeName == 'ar'
                    //                     ? 'العربية'
                    //                     : (l10n.localeName == 'de'
                    //                           ? 'Deutsch'
                    //                           : (l10n.localeName == 'fr'
                    //                                 ? 'Français'
                    //                                 : 'English')),
                    //                 style: TextStyle(
                    //                   color: AppColors.textTertiary,
                    //                   fontSize: AppSizes.smallSize(
                    //                     context,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           const Icon(
                    //             Icons.language,
                    //             color: AppColors.orangeAccent,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    // Menu Items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLarge,
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
                          children: [
                            _buildCustomMenuItem(
                              context,
                              l10n.myChildren,
                              '${l10n.children} - ${user.children?.length ?? 0}',
                              Icons.child_care_outlined,
                              () => _showChildrenBottomSheet(context),
                            ),
                            const Divider(height: 1, indent: 20, endIndent: 20),
                            _buildCustomMenuItem(
                              context,
                              l10n.editProfile,
                              l10n.updateYourInfo,
                              Icons.edit_outlined,
                              () => context
                                  .push(Routes.editProfile, extra: user)
                                  .then((_) {
                                    if (context.mounted) {
                                      context.read<ProfileCubit>().getProfile();
                                    }
                                  }),
                            ),
                            const Divider(height: 1, indent: 20, endIndent: 20),
                            _buildCustomMenuItem(
                              context,
                              l10n.changePassword,
                              l10n.updatePassword,
                              Icons.lock_outline,
                              () => context.push(Routes.changePassword),
                            ),
                            // Commented out for App Store submission - non-functional buttons
                            // const Divider(height: 1, indent: 20, endIndent: 20),
                            // _buildCustomMenuItem(
                            //   context,
                            //   l10n.notifications,
                            //   l10n.manageNotifications,
                            //   Icons.notifications_none_outlined,
                            //   () {},
                            // ),
                            // const Divider(height: 1, indent: 20, endIndent: 20),
                            // _buildCustomMenuItem(
                            //   context,
                            //   l10n.privacySecurity,
                            //   l10n.controlYourData,
                            //   Icons.security_outlined,
                            //   () {},
                            // ),
                            // const Divider(height: 1, indent: 20, endIndent: 20),
                            // _buildCustomMenuItem(
                            //   context,
                            //   l10n.helpSupport,
                            //   l10n.getHelp,
                            //   Icons.help_outline,
                            //   () {},
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () => context.go(Routes.login),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.designOrange),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout,
                                color: AppColors.designOrange,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.logout,
                                style: TextStyle(
                                  color: AppColors.designOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.bodySize(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ].animate(interval: 50.ms).fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
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

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.bodySize(context),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Icon(icon, color: iconColor),
        ],
      ),
    );
  }

  Widget _buildCustomMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lightOrange, // Standardized light orange
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Icon(icon, color: AppColors.deepOrange),
      ),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: AppSizes.bodySize(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: AppSizes.smallSize(context),
        ),
      ),
      leading: Icon(
        Icons.arrow_back_ios,
        size: AppSizes.bodySize(context),
        color: AppColors.textTertiary,
      ),
    );
  }

  void _showChildrenBottomSheet(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: profileCubit,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusExtraLarge),
            ),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.myChildren,
                      style: AppTextStyles.heading(context),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Children List
              Expanded(child: const ChildrenListView()),
            ],
          ),
        ),
      ),
    );
  }
}
