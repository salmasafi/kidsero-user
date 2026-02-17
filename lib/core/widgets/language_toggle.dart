import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';

import '../logic/locale_cubit.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    this.showBackground = true,
    this.iconColor,
  });

  final bool showBackground;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary;
    final iconButton = IconButton(
      icon: Icon(
        Icons.translate,
        color: iconColor ?? primaryColor,
        size: 20,
      ),
      onPressed: () => showLanguageDialog(context),
    );

    if (!showBackground) {
      return iconButton;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: iconButton,
    );
  }
}

void showLanguageDialog(BuildContext context) {
  final localeCubit = context.read<LocaleCubit>();
  final currentLocale = Localizations.localeOf(context).languageCode;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Select Language',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          textAlign: TextAlign.center,
        ),
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
            const SizedBox(height: 12),
            _LanguageOption(
              label: 'العربية',
              code: 'ar',
              isSelected: currentLocale == 'ar',
              onTap: () {
                localeCubit.changeLocale('ar');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              label: 'Deutsch',
              code: 'de',
              isSelected: currentLocale == 'de',
              onTap: () {
                localeCubit.changeLocale('de');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
