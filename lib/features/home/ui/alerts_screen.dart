import 'package:flutter/material.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';

/// Alerts/Notifications screen - placeholder for now
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B59B6),
        elevation: 0,
        title: Text(
          l10n.alerts,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Open notification settings
            },
          ),
        ],
      ),
      body: CustomEmptyState(
        icon: Icons.notifications_off_outlined,
        title: l10n.alerts,
        message: l10n.somethingWentWrong,
      ),
    );
  }
}
