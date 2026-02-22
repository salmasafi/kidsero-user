import 'package:flutter/material.dart';
import 'package:kidsero_parent/features/home/ui/alerts_screen.dart';
import 'package:kidsero_parent/features/home/ui/track_screen.dart';
import 'package:kidsero_parent/features/payments/ui/view/payments_view.dart';
import 'package:kidsero_parent/features/profile/ui/view/profile_view.dart';
import 'package:kidsero_parent/features/rides/ui/screens/rides_screen.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Define your screens here
  final List<Widget> _screens = [
    const RidesScreen(), // Home - Shows children dashboard
    const TrackScreen(), // Track - Shows active rides for tracking
    const PaymentsScreen(), // Payments
    const AlertsScreen(), // Alerts/Notifications
    const ProfileView(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.location_on_outlined),
              activeIcon: const Icon(Icons.location_on),
              label: l10n.track,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.payment_outlined),
              activeIcon: const Icon(Icons.payment),
              label: l10n.payments,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications_outlined),
              activeIcon: const Icon(Icons.notifications),
              label: l10n.alerts,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
