import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'routes.dart';

/// Root SeatVue application widget.
class SeatVueApp extends StatelessWidget {
  const SeatVueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeatVue',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
