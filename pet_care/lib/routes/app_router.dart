import 'package:flutter/material.dart';
import 'package:pet_care/features/home/pet_profile_ui/profile_screen.dart';
import 'package:pet_care/features/home/settings_ui/account_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/vet_signup_screen.dart';
import '../features/banner/first_banner_screen.dart';
import '../features/home/home_screen.dart';
import '../features/vet_home/vet_home_screen.dart';

class AppRoutes {
  static const String banner = '/banner';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupVet = '/signup-vet';
  static const String home = '/home';
  static const String vetHome = '/vet-home';
  static const String profile = '/profile_screen';
  static const String booking = '/booking';
  static const String chat = '/chat';
  static const String account = '/AccountScreen';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    print("Navigating to: ${settings.name}"); // Debug log

    switch (settings.name) {
      case banner:
        return MaterialPageRoute(builder: (_) => FirstBannerScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case signupVet:
        return MaterialPageRoute(builder: (_) => SignupVetScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case vetHome:
        return MaterialPageRoute(builder: (_) => VetHomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case booking:
      //  return MaterialPageRoute(builder: (_) => BookingScreen());
      case chat:
     //   return MaterialPageRoute(builder: (_) => ChatScreen());
      case account:
        return MaterialPageRoute(builder: (_) => AccountScreen());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
