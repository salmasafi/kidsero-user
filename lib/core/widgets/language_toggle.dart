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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: DropdownButton<String>(
        value: currentLocale,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8B5CF6), size: 20),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('EN')),
          DropdownMenuItem(value: 'ar', child: Text('AR')),
          DropdownMenuItem(value: 'de', child: Text('DE')),
          DropdownMenuItem(value: 'fr', child: Text('FR')),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            handleChange(newValue);
          }
        },
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B5CF6),
          fontFamily: 'Cairo',
        ),
      ),
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
