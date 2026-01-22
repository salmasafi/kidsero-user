import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/theme/app_text_styles.dart';
import 'package:kidsero_driver/core/theme/app_sizes.dart';

import 'package:kidsero_driver/core/widgets/custom_loading.dart';
import 'package:kidsero_driver/core/widgets/custom_error_widget.dart';
import 'package:kidsero_driver/features/profile/logic/cubit/profile_cubit.dart';
import 'package:kidsero_driver/features/profile/logic/cubit/profile_state.dart';
import 'package:kidsero_driver/features/profile/data/models/children_response_model.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kidsero_driver/core/widgets/custom_button.dart';
import 'package:kidsero_driver/core/widgets/custom_text_field.dart';
import 'package:kidsero_driver/core/widgets/custom_snackbar.dart';

class ChildrenListView extends StatefulWidget {
  const ChildrenListView({super.key});

  @override
  State<ChildrenListView> createState() => _ChildrenListViewState();
}

class _ChildrenListViewState extends State<ChildrenListView> {
  @override
  void initState() {
    super.initState();
    // Load children when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileCubit>().getChildren();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is AddChildSuccess) {
          // Check if dialog is open (can be tricky, but usually we pop the dialog in the dialog action or manually)
          // Here we just show snackbar. The dialog is better closed by Navigator.pop inside the dialog itself or here?
          // If we close it here, we might close the sheet.
          // Let's assume the dialog is modal and we pop it.
          // But wait, the listener triggers on the sheet context.
          CustomSnackbar.showSuccess(context, state.message);
        } else if (state is AddChildError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is ChildrenLoading || state is AddChildLoading) {
          return const CustomLoading();
        } else if (state is ChildrenLoaded) {
          if (state.children.isEmpty) {
            return _buildEmptyState(context, l10n);
          }
          return _buildChildrenList(context, state.children, l10n);
        } else if (state is ChildrenError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () => context.read<ProfileCubit>().getChildren(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.child_care_outlined,
              size: 60,
              color: AppColors.designPurple,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noChildrenFound,
            style: AppTextStyles.heading(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.noChildrenDescription,
            style: AppTextStyles.body(
              context,
            ).copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          CustomButton(
            text: 'Add Child', // TODO: Use l10n
            onPressed: () => _showAddChildDialog(context),
            width: 200,
            gradient: AppColors.parentGradient,
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildChildrenList(
    BuildContext context,
    List<ChildModel> children,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(l10n.myChildren, style: AppTextStyles.heading(context)),
          // IconButton(
          //   onPressed: () => _showAddChildDialog(context),
          //   icon: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: AppColors.designPurple.withValues(alpha: 0.1),
          //       shape: BoxShape.circle,
          //     ),
          //     child: Icon(Icons.add, color: AppColors.designPurple, size: 20),
          //   ),
          // ),
          //   ],
          // ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final child = children[index];
              return _buildChildCard(context, child, l10n, index);
            },
          ),
          const SizedBox(height: 30),
          CustomButton(
            text: 'Add Child', // TODO: Use l10n
            onPressed: () => _showAddChildDialog(context),
            width: 200,
            gradient: AppColors.parentGradient,
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(
    BuildContext context,
    ChildModel child,
    AppLocalizations l10n,
    int index,
  ) {
    return InkWell(
          onTap: () => _showChildDetails(context, child, l10n),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Child Avatar
                Hero(
                  tag: 'child_avatar_${child.id}',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.designPurple.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/child_default.png',
                        fit: BoxFit.cover,
                      ),
                      // child.avatar != null && child.avatar!.isNotEmpty
                      //     ? CachedNetworkImage(
                      //         imageUrl: ApiEndpoints.getImageUrl(child.avatar!),
                      //         fit: BoxFit.cover,
                      //         placeholder: (context, url) => Image.asset(
                      //           'assets/images/child_default.png',
                      //           fit: BoxFit.cover,
                      //         ),
                      //         errorWidget: (context, url, error) => Image.asset(
                      //           'assets/images/child_default.png',
                      //           fit: BoxFit.cover,
                      //         ),
                      //       )
                      //     : Image.asset(
                      //         'assets/images/child_default.png',
                      //         fit: BoxFit.cover,
                      //       ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Child Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        child.name,
                        style: AppTextStyles.subHeading(context),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.designPurple.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              child.grade,
                              style: TextStyle(
                                color: AppColors.designPurple,
                                fontSize: AppSizes.smallSize(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              child.classroom,
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: AppSizes.smallSize(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            child.status == 'active'
                                ? Icons.check_circle
                                : Icons.pause_circle,
                            size: 16,
                            color: child.status == 'active'
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            child.status == 'active'
                                ? l10n.active
                                : l10n.inactive,
                            style: TextStyle(
                              color: child.status == 'active'
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontSize: AppSizes.smallSize(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textTertiary,
                  size: AppSizes.bodySize(context),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .fade(duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  void _showChildDetails(
    BuildContext context,
    ChildModel child,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChildDetailsSheet(child: child),
    );
  }

  void _showAddChildDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final profileCubit = context.read<ProfileCubit>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Child', // TODO: Localize
          style: AppTextStyles.heading(context),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the code of your child to add them to your profile', // TODO: Localize
              style: AppTextStyles.body(context).copyWith(
                color: AppColors.textSecondary,
                fontSize: AppSizes.smallSize(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: codeController,
              label: 'Child Code', // TODO: Localize
              icon: Icons.qr_code,
              hintText: 'Enter code',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel', // TODO: Localize
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (codeController.text.isNotEmpty) {
                profileCubit.addChild(codeController.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add', // TODO: Localize
              style: TextStyle(
                color: AppColors.designPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChildDetailsSheet extends StatelessWidget {
  final ChildModel child;

  const ChildDetailsSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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

          // Child Avatar and Name
          Hero(
            tag: 'child_avatar_${child.id}',
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.designPurple.withValues(alpha: 0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/child_default.png',
                  fit: BoxFit.cover,
                ),
                // child.avatar != null && child.avatar!.isNotEmpty
                //     ? CachedNetworkImage(
                //         imageUrl: ApiEndpoints.getImageUrl(child.avatar!),
                //         fit: BoxFit.cover,
                //         placeholder: (context, url) => Image.asset(
                //           'assets/images/child_default.png',
                //           fit: BoxFit.cover,
                //         ),
                //         errorWidget: (context, url, error) => Image.asset(
                //           'assets/images/child_default.png',
                //           fit: BoxFit.cover,
                //         ),
                //       )
                //     : Image.asset(
                //         'assets/images/child_default.png',
                //         fit: BoxFit.cover,
                //       ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(child.name, style: AppTextStyles.heading(context)),
          const SizedBox(height: 30),

          // Details List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    l10n.grade,
                    child.grade,
                    Icons.school_outlined,
                    AppColors.designPurple,
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    context,
                    l10n.classroom,
                    child.classroom,
                    Icons.meeting_room_outlined,
                    AppColors.gold,
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    context,
                    l10n.status,
                    child.status == 'active' ? l10n.active : l10n.inactive,
                    child.status == 'active'
                        ? Icons.check_circle
                        : Icons.pause_circle,
                    child.status == 'active'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDetailRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.smallSize(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
