import 'package:flutter/material.dart';
import 'package:pet_care/features/vet_home/vet_home_ui/vet_home_main_screen.dart';

import '../../widgets/bottom_nav_bar.dart';




class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<VetHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    VetHomeMainScreen(),
    Center(child: Text('Đặt lịch')),  // Placeholder cho các tab khác
    Center(child: Text('Hồ sơ')),
    Center(child: Text('Chat')),
    Center(child: Text('Tài khoản')),
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