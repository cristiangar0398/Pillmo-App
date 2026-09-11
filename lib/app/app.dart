import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/theme/theme_cubit.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';

class PillmoApp extends StatelessWidget {
  const PillmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Self-provided via GetIt, like LoginPage does for AuthCubit, so this
    // widget renders standalone (e.g. in widget tests) without depending on
    // main.dart's MultiBlocProvider to supply a ThemeCubit ancestor.
    return BlocProvider<ThemeCubit>.value(
      value: getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Pillmo',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
