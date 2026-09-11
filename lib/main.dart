import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/observers/bloc_observer.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/blocs/auth_cubit.dart';
import 'features/calendar/presentation/blocs/calendar_cubit.dart';
import 'features/medications/presentation/blocs/medications_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Guarded because DefaultFirebaseOptions.currentPlatform only covers web
  // today (see firebase_options.dart) — a non-web target would otherwise
  // crash the whole app at startup instead of just disabling sign-in.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error) {
    debugPrint(
        'Firebase no se pudo inicializar ($error). El login con email y Google no funcionará hasta configurar un proyecto real.');
  }
  await configureDependencies();
  Bloc.observer = AppBlocObserver();
  final authCubit = getIt<AuthCubit>();
  await authCubit.checkAuthStatus();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<MedicationCubit>(
          create: (_) => getIt<MedicationCubit>(),
        ),
        BlocProvider<CalendarCubit>(
          create: (_) => getIt<CalendarCubit>(),
        ),
      ],
      child: const PillmoApp(),
    ),
  );
}
