import 'package:flutter/material.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/core/widgets/language_toggle.dart';

import '../../../core/theme/app_colors.dart';

/// Alerts/Notifications screen - placeholder for now
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Elegant gradient header
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.parentGradient,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.alerts,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Language button
                    IconButton(
                      onPressed: () => showLanguageDialog(context),
                      icon: const Icon(
                        Icons.translate,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Body content
          Expanded(
            child: CustomEmptyState(
              icon: Icons.notifications_off_outlined,
              title: l10n.alerts,
              message: l10n.somethingWentWrong,
            ),
          ),
        ],
      ),
    );
  }
}
