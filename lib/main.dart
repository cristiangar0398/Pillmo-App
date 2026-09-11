import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/observers/bloc_observer.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/blocs/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  Bloc.observer = AppBlocObserver();
  final authCubit = getIt<AuthCubit>();
  await authCubit.checkAuthStatus();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: const PillmoApp(),
    ),
  );
}
