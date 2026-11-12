import 'package:flutter/material.dart';
import 'package:pvm/core/constants/app_constants.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/features/checkout/presentation/screens/pos_home_screen.dart';

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const PosHomeScreen(),
    );
  }
}
