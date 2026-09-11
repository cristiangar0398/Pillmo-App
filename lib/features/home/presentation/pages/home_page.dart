import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../appointments/presentation/pages/appointments_page.dart';
import '../../../auth/presentation/blocs/auth_cubit.dart';
import '../../../../core/widgets/pillmo_logo.dart';
import '../../../medications/presentation/pages/medications_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.userName,
    required this.userId,
  });

  final String userName;
  final String userId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TimelinePage(userId: widget.userId),
      AppointmentsPage(userId: widget.userId),
      MedicationAgendaPage(userId: widget.userId),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PillmoLogo(size: 32, showName: false),
            SizedBox(width: 10),
            Text('Pillmo'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthCubit>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 80,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _currentIndex = index),
                    destinations: const [
                      NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Inicio'),
                      NavigationDestination(
                          icon: Icon(Icons.calendar_today_outlined),
                          label: 'Familia'),
                      NavigationDestination(
                          icon: Icon(Icons.view_timeline_outlined),
                          label: 'Agenda'),
                      NavigationDestination(
                          icon: Icon(Icons.person_outline), label: 'Perfil'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab_add_prescription',
        shape: const CircleBorder(),
        onPressed: () =>
            showMedicationActionSheet(context, userId: widget.userId),
        tooltip: 'Incluir receta o medicamento',
        child: const Icon(Icons.add),
      ),
    );
  }
}
