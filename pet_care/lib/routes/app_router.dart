import 'package:flutter/material.dart';
import '../features/auth/auth_screen.dart';

class AppRouter {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/auth':
        return MaterialPageRoute(builder: (_) => AuthScreen());
      default:
        return MaterialPageRoute(builder: (_) => AuthScreen());
    }
  }
}