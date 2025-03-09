import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/features/vet_home/setting_ui/vet_account_screen.dart';
import 'package:pet_care/features/vet_home/vet_booking_ui/vet_booking_screen.dart';
import 'package:pet_care/features/vet_home/vet_home_ui/vet_home_main_screen.dart';
import 'package:pet_care/features/vet_home/vet_records_ui/vet_records_screen.dart'; // Import VetRecordScreen
import '../../widgets/bottom_nav_bar.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  _VetHomeScreenState createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Danh sách các màn hình
  final List<Widget> _screens = [
    VetHomeMainScreen(),
    VetBookingScreen(),
    VetRecordsScreen(vetId: FirebaseAuth.instance.currentUser?.uid ?? ""),
    Center(child: Text('Chat')),
    VetAccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Đặt lại Navigator về trang đầu tiên của màn hình hiện tại
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _screens[_selectedIndex],
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
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