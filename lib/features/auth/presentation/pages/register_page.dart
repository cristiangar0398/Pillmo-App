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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  late final AuthCubit _authCubit;
  String _role = 'PATIENT';

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    _authCubit.register(
      email: emailController.text.trim(),
      password: passwordController.text,
      fullName: fullNameController.text.trim(),
      role: _role,
    );
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
                      context.go('/home');
                    }
                    if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                    if (state is AuthRoleRequired) {
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
                          const SizedBox(height: 40),
                          const PillmoLogo(size: 72),
                          const SizedBox(height: 24),
                          Text(
                            'Crea tu cuenta',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Regístrate para empezar a organizar tus tratamientos.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          GlassContainer(
                            borderRadius: BorderRadius.circular(28),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Soy',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                RoleSelector(
                                  role: _role,
                                  onChanged: (role) =>
                                      setState(() => _role = role),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: fullNameController,
                                  label: 'Nombre completo',
                                ),
                                const SizedBox(height: 16),
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
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: confirmPasswordController,
                                  label: 'Confirmar contraseña',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 24),
                                if (isLoading)
                                  const Center(
                                      child: CircularProgressIndicator())
                                else ...[
                                  AppButton(
                                    label: 'Crear cuenta',
                                    onPressed: _submit,
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
                                    onPressed: () => _authCubit
                                        .signInWithGoogle(role: _role),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
