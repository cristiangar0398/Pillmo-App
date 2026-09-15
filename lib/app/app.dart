import 'package:flutter/material.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';

class PillmoApp extends StatelessWidget {
  const PillmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pillmo',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
