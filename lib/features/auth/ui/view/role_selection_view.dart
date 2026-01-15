import 'package:flutter/material.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/theme/app_text_styles.dart';
import 'package:kidsero_driver/core/theme/app_sizes.dart';
import 'package:kidsero_driver/core/utils/enums.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/core/routing/routes.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/logic/locale_cubit.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  void _showLanguageDialog(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();
    final currentLocale = Localizations.localeOf(context).languageCode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOption(
                label: 'English',
                code: 'en',
                isSelected: currentLocale == 'en',
                onTap: () {
                  localeCubit.changeLocale('en');
                  Navigator.pop(context);
                },
              ),
              _LanguageOption(
                label: 'العربية',
                code: 'ar',
                isSelected: currentLocale == 'ar',
                onTap: () {
                  localeCubit.changeLocale('ar');
                  Navigator.pop(context);
                },
              ),
              _LanguageOption(
                label: 'Deutsch',
                code: 'de',
                isSelected: currentLocale == 'de',
                onTap: () {
                  localeCubit.changeLocale('de');
                  Navigator.pop(context);
                },
              ),
              _LanguageOption(
                label: 'Français',
                code: 'fr',
                isSelected: currentLocale == 'fr',
                onTap: () {
                  localeCubit.changeLocale('fr');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Bar with Language Toggle
            Positioned(
              top: 10,
              left: isArabic ? 20 : null,
              right: isArabic ? null : 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.translate,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                  onPressed: () {
                    // Show language selection dialog or bottom sheet
                    _showLanguageDialog(context);
                  },
                ),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Branding
                  const Text(
                    '🚌',
                    style: TextStyle(fontSize: 80),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    isArabic ? 'كيدزيرو' : 'Kidsero',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      fontFamily: 'Cairo',
                      letterSpacing: 1.2,
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    isArabic ? 'رحلات آمنة لأطفالكم' : l10n.safeRides,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Cairo',
                    ),
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    isArabic ? 'أهلاً وسهلاً! 👋' : 'Welcome! 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      fontFamily: 'Cairo',
                    ),
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    isArabic ? 'الرجاء اختيار دورك للمتابعة' : l10n.selectRole,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Cairo',
                    ),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 40),

                  // Role Cards
                  _RoleCard(
                    title: isArabic ? 'أنا ولي أمر' : l10n.imParent,
                    description: isArabic ? 'تتبع حافلة طفلك، تواصل مع السائقين، وإدارة الاستلامات' : l10n.imParentDesc,
                    icon: Icons.person_outline,
                    color: const Color(0xFF8B5CF6),
                    tagText: isArabic ? 'انضم لأكثر من 1,200 ولي أمر' : l10n.joinParents('1,200'),
                    tagEmojis: isArabic ? '👱‍♀️ 👦' : '👱‍♀️ 👦',
                    onTap: () => context.push(Routes.login, extra: UserRole.parent),
                  )
                      .animate(delay: 600.ms)
                      .fade(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 20),

                  _RoleCard(
                    title: isArabic ? 'أنا سائق' : l10n.imDriver,
                    description: isArabic ? 'إدارة مسارك، إعلام الأولياء، وضمان الرحلات الآمنة' : l10n.imDriverDesc,
                    icon: Icons.local_shipping_outlined,
                    color: const Color(0xFF0D9488),
                    tagText: isArabic ? 'شبكة سائقين موثوقين' : l10n.trustedDrivers,
                    tagEmojis: isArabic ? '🚌 🗺️' : '🚌 🗺️',
                    onTap: () => context.push(Routes.login, extra: UserRole.driver),
                  )
                      .animate(delay: 800.ms)
                      .fade(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),

                  const Spacer(flex: 3),
                  
                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Cairo',
                          color: Color(0xFF6B7280),
                        ),
                        children: [
                          TextSpan(
                            text: isArabic ? 'بالمتابعة، أنت توافق على ' : '${l10n.byContinuing} ',
                            style: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                          TextSpan(
                            text: isArabic ? 'شروط الخدمة' : l10n.termsOfService,
                            style: const TextStyle(
                              color: Color(0xFFFA8231),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Cairo',
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tagEmojis,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tagText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
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

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
