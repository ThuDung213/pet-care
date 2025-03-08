import 'package:flutter/material.dart';
import 'package:pet_care/features/home/booking_ui/booking_screen.dart';
import 'package:pet_care/features/home/home_ui/home_main_screen.dart';
import 'package:pet_care/features/home/pet_profile_ui/profile_screen.dart';
import 'package:pet_care/features/home/settings_ui/account_screen.dart';

import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeMainScreen(),
    BookingScreen(),
    ProfileScreen(),
    Center(child: Text('Chat')),
    AccountScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
