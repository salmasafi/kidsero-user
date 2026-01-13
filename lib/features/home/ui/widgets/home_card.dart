import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final String description;

  const HomeCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }
}
