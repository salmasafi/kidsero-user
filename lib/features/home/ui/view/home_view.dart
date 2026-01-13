import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/routing/routes.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(Routes.profile),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome Home!',
          style: AppTextStyles.heading(context),
        ).animate().fade(duration: 800.ms).scale(delay: 200.ms),
      ),
    );
  }
}
