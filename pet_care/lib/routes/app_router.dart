import 'package:flutter/material.dart';
import 'package:pet_care/features/banner/first_banner_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/vet_signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/vet_home/vet_home_screen.dart';

class AppRoutes {
  static const String banner = '/banner';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupVet = '/signup-vet';
  static const String home = '/home';
  static const String vetHome = '/vet-home';


  static Route<dynamic> generateRoute(RouteSettings settings) {
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
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
