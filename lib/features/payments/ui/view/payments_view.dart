import 'package:flutter/material.dart';
import 'package:kidsero_driver/features/payments/ui/view/payment_history_view.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/app_services_tab.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/school_services_tab.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF9B59B6),
          elevation: 0,
          title: Text(
            l10n.payments,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentHistoryScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
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
                colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [AppServicesTab(), SchoolServicesTab()],
        ),
      ),
    );
  }
}
