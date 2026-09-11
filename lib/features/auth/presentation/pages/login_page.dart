import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/pillmo_logo.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../blocs/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController(text: 'paciente.qa@pillmo.com');
  final fullNameController = TextEditingController(text: 'Juan Perez QA');
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _authCubit.checkAuthStatus();
  }

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Scaffold(
        body: SafeArea(
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

                if (state is Unauthenticated) {
                  context.go('/login');
                }

                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;

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
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                controller: emailController,
                                label: 'Correo electrónico',
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: fullNameController,
                                label: 'Nombre completo',
                              ),
                              const SizedBox(height: 24),
                              if (isLoading)
                                const Center(child: CircularProgressIndicator())
                              else
                                AppButton(
                                  label: 'Ingresar a Pillmo',
                                  onPressed: () {
                                    _authCubit.syncUser(
                                      firebaseUid: 'qa-firebase-user-123',
                                      email: emailController.text.trim(),
                                      fullName: fullNameController.text.trim(),
                                      role: 'patient',
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
