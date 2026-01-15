import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../logic/locale_cubit.dart';

class LanguageToggle extends StatelessWidget {
  final bool popAfterSelect;
  const LanguageToggle({super.key, this.popAfterSelect = false});

  @override
  Widget build(BuildContext context) {
    // Use watch to ensure this widget rebuilds when state changes
    final localeCubit = context.watch<LocaleCubit>();
    final currentLocale = Localizations.localeOf(context).languageCode;

    void handleChange(String code) {
      localeCubit.changeLocale(code);
      if (popAfterSelect) {
        Navigator.pop(context);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LanguageOption(
          label: 'EN',
          isActive: currentLocale == 'en',
          onTap: () => handleChange('en'),
        ),
        const SizedBox(width: 8),
        _LanguageOption(
          label: 'AR',
          isActive: currentLocale == 'ar',
          onTap: () => handleChange('ar'),
        ),
        const SizedBox(width: 8),
        _LanguageOption(
          label: 'DE',
          isActive: currentLocale == 'de',
          onTap: () => handleChange('de'),
        ),
        const SizedBox(width: 8),
        _LanguageOption(
          label: 'FR',
          isActive: currentLocale == 'fr',
          onTap: () => handleChange('fr'),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.textTertiary.withOpacity(0.1),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.getFontFamily(context),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
