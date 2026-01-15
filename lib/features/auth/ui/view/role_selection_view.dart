import 'package:flutter/material.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/theme/app_text_styles.dart';
import 'package:kidsero_driver/core/theme/app_sizes.dart';
import 'package:kidsero_driver/core/utils/enums.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/core/routing/routes.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/widgets/language_toggle.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Top Bar with Language Toggle
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: const LanguageToggle()
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.padding(context)),
              child: Column(
                children: [
                  const Spacer(),
                  // Branding
                  const Text(
                    '🚌',
                    style: TextStyle(fontSize: 80),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  SizedBox(height: AppSizes.spacing(context)),
                  Text(
                    'Kidsero',
                    style: AppTextStyles.heading(context).copyWith(
                      fontSize: 32,
                      letterSpacing: 1.2,
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  Text(
                    l10n.safeRides,
                    style: AppTextStyles.subHeading(context).copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  SizedBox(height: AppSizes.spacing(context) * 2),
                  Text(
                    'Welcome! 👋',
                    style: AppTextStyles.heading(context).copyWith(fontSize: 24),
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  Text(
                    l10n.selectRole,
                    style: AppTextStyles.subHeading(context),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  SizedBox(height: AppSizes.spacing(context) * 3),

                  // Role Cards
                  _RoleCard(
                    title: l10n.imParent,
                    description: l10n.imParentDesc,
                    icon: Icons.person_outline,
                    color: const Color(0xFF8B5CF6),
                    tagText: l10n.joinParents('1,200'),
                    tagEmojis: '👱‍♀️ 👦',
                    onTap: () => context.push(Routes.login, extra: UserRole.parent),
                  )
                      .animate(delay: 600.ms)
                      .fade(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  SizedBox(height: AppSizes.spacing(context) * 1.5),

                  _RoleCard(
                    title: l10n.imDriver,
                    description: l10n.imDriverDesc,
                    icon: Icons.local_shipping_outlined,
                    color: const Color(0xFF0D9488),
                    tagText: l10n.trustedDrivers,
                    tagEmojis: '🚌 🗺️',
                    onTap: () => context.push(Routes.login, extra: UserRole.driver),
                  )
                      .animate(delay: 800.ms)
                      .fade(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),

                  const Spacer(),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.body(context).copyWith(fontSize: 12),
                        children: [
                          TextSpan(
                            text: '${l10n.byContinuing} ',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          TextSpan(
                            text: l10n.termsOfService,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 1.seconds),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String tagText;
  final String tagEmojis;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tagText,
    required this.tagEmojis,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.heading(context).copyWith(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTextStyles.body(context).copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(tagEmojis, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        tagText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
