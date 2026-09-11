import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/pillmo_logo.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/widgets/role_selector.dart';
import '../blocs/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late final AuthCubit _authCubit;
  String _pendingGoogleRole = 'PATIENT';

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _authCubit.checkAuthStatus();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _promptRoleAndRetryGoogle() async {
    final role = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        var selected = _pendingGoogleRole;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Primero, cuéntanos quién eres',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    RoleSelector(
                      role: selected,
                      onChanged: (role) =>
                          setSheetState(() => selected = role),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Continuar',
                      onPressed: () => Navigator.of(sheetContext).pop(selected),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (role != null) {
      _pendingGoogleRole = role;
      unawaited(_authCubit.signInWithGoogle(role: role));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const GlassBackground(),
            SafeArea(
              child: ResponsiveCenter(
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is Authenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Bienvenido ${state.user.fullName ?? state.user.email}'),
                        ),
                      );
                      context.go('/home');
                    }

                    if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }

                    if (state is AuthRoleRequired) {
                      _promptRoleAndRetryGoogle();
                    }
                  },
                  builder: (context, state) {
                    final isLoading =
                        state is AuthLoading || state is AuthRoleRequired;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 52),
                          const PillmoLogo(size: 82),
                          const SizedBox(height: 30),
                          Text(
                            'Tu día, más ligero',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pillmo te ayuda a recordar tus tratamientos sin llenar tu cabeza de pendientes.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 28),
                          GlassContainer(
                            borderRadius: BorderRadius.circular(28),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppTextField(
                                  controller: emailController,
                                  label: 'Correo electrónico',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: passwordController,
                                  label: 'Contraseña',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 24),
                                if (isLoading)
                                  const Center(
                                      child: CircularProgressIndicator())
                                else ...[
                                  AppButton(
                                    label: 'Ingresar a Pillmo',
                                    onPressed: () {
                                      _authCubit.login(
                                        email: emailController.text.trim(),
                                        password: passwordController.text,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Divider(
                                              color: context.glass.muted)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12),
                                        child: Text('o',
                                            style: TextStyle(
                                                color: context.glass.muted)),
                                      ),
                                      Expanded(
                                          child: Divider(
                                              color: context.glass.muted)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  GoogleSignInButton(
                                    onPressed: () =>
                                        _authCubit.signInWithGoogle(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('¿No tienes cuenta? Regístrate'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
