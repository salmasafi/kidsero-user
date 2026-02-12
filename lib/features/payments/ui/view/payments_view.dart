import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/core/routing/routes.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/app_services_tab.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text(
            l10n.payments,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // Payment History button
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              tooltip: 'Payment History',
              onPressed: () {
                context.push(Routes.paymentHistory);
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 15,
            ),
            tabs: [
              Tab(text: l10n.appServices),
              Tab(text: l10n.schoolServices),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [const AppServicesTab(), Container()],
        ),
      ),
    );
  }
}
