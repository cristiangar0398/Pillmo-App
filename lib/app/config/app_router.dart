import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../features/auth/presentation/blocs/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/medications/presentation/pages/medications_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final authCubit = getIt<AuthCubit>();
    final isAuthenticated = authCubit.state is Authenticated;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    if (isAuthenticated && isAuthRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final authCubit = getIt<AuthCubit>();
        final user = (authCubit.state as Authenticated).user;
        return HomePage(
          userName: user.fullName ?? user.email,
          userId: user.id,
        );
      },
    ),
    GoRoute(
      path: '/medications/scan',
      builder: (context, state) {
        final user = (getIt<AuthCubit>().state as Authenticated).user;
        return PrescriptionScanPage(userId: user.id);
      },
    ),
  ],
);
