import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/presentation/blocs/auth_cubit.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/responsive_center.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user = state is Authenticated ? state.user : null;
            final glass = context.glass;

            return Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [glass.mintPale, glass.surface],
                    ),
                    border: Border.all(color: glass.surfaceBorder, width: 3),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x1A16233D),
                          blurRadius: 20,
                          offset: Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.person,
                      size: 44, color: AppTheme.mintDeep),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Juan Perez QA',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(user?.email ?? 'paciente.qa@pillmo.com',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _ProfileRow(
                            label: 'Rol', value: user?.role ?? 'Paciente'),
                        _ProfileRow(
                            label: 'Contacto de emergencia',
                            value: '+52 55 1234 5678'),
                        _ProfileRow(label: 'Plan', value: 'Premium'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tema',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, color: glass.ink)),
                        const SizedBox(height: 12),
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, themeMode) {
                            return SegmentedButton<ThemeMode>(
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.brightness_auto_outlined),
                                  label: Text('Sistema'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_outlined),
                                  label: Text('Claro'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_outlined),
                                  label: Text('Oscuro'),
                                ),
                              ],
                              selected: {themeMode},
                              onSelectionChanged: (selection) => context
                                  .read<ThemeCubit>()
                                  .setThemeMode(selection.first),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final authCubit = context.read<AuthCubit>();
                      await getIt<AuthLocalDataSource>().deleteUser();
                      await authCubit.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger.withOpacity(.12),
                      foregroundColor: AppTheme.danger,
                      side: BorderSide(color: AppTheme.danger.withOpacity(.3)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
