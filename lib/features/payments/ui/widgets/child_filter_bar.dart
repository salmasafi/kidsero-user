import 'package:flutter/material.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';

class ChildFilterOption<T> {
  final String id;
  final String label;
  final T? payload;

  const ChildFilterOption({
    required this.id,
    required this.label,
    this.payload,
  });
}

class ChildFilterBar<T> extends StatelessWidget {
  final String label;
  final List<ChildFilterOption<T>> options;
  final String? selectedOptionId;
  final ValueChanged<ChildFilterOption<T>?> onOptionSelected;
  final bool showAllOption;
  final String allChipLabel;
  final EdgeInsetsGeometry? padding;

  const ChildFilterBar({
    super.key,
    required this.label,
    required this.options,
    required this.onOptionSelected,
    this.selectedOptionId,
    this.showAllOption = false,
    this.allChipLabel = 'All',
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (showAllOption)
                ChoiceChip(
                  label: Text(allChipLabel),
                  selected: selectedOptionId == null,
                  onSelected: (selected) {
                    if (selected) {
                      onOptionSelected(null);
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selectedOptionId == null
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                  checkmarkColor: Colors.white,
                ),
              ...options.map((option) {
                final isSelected = selectedOptionId == option.id;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onOptionSelected(option);
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  checkmarkColor: Colors.white,
                );
              }),
            ],
          ),
        ],
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: content);
    }

    return content;
  }
}
