import 'package:flutter/material.dart';
import 'package:kidsero_driver/features/children/ui/screens/children_screen.dart';
import 'package:kidsero_driver/features/plans/ui/screens/plans_screen.dart';
import 'package:kidsero_driver/features/profile/ui/view/profile_view.dart';
import 'package:kidsero_driver/features/rides/ui/screens/rides_screen.dart'; // Your existing Home
// Import PlansScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Define your screens here
  final List<Widget> _screens = [
    RidesScreen(), // Your existing Rides screen
    const PlansScreen(),
    const ChildrenScreen(),
    ProfileView()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Children',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
