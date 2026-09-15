import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/presentation/blocs/auth_cubit.dart';
import '../../../../core/di/injection.dart';
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

            return Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  child: Icon(Icons.person, size: 42),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Juan Perez QA',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(user?.email ?? 'paciente.qa@pillmo.com'),
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
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await getIt<AuthLocalDataSource>().deleteUser();
                      await context.read<AuthCubit>().logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
