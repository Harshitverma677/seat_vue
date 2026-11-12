import 'package:flutter/material.dart';
import '../features/home/screens/home_screen.dart';

/// App route definitions.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}
