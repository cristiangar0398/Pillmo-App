import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../appointments/presentation/pages/appointments_page.dart';
import '../../../auth/presentation/blocs/auth_cubit.dart';
import '../../../calendar/presentation/pages/calendar_page.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/pillmo_logo.dart';
import '../../../medications/presentation/blocs/medications_cubit.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MedicationCubit>().loadTodayTimeline(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final role =
        authState is Authenticated ? authState.user.role?.toUpperCase() : null;
    // "Familia" only has content for caregivers — for a patient with no
    // linked caregiver network it would always render an empty state, so it
    // isn't worth the tab.
    final isCaregiver = role == 'CAREGIVER';

    final pages = <Widget>[
      TimelinePage(userId: widget.userId),
      CalendarPage(userId: widget.userId),
      if (isCaregiver) AppointmentsPage(userId: widget.userId),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: GlassContainer(
              borderRadius: BorderRadius.circular(22),
              blurSigma: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    const PillmoLogo(size: 32, showName: false),
                    const SizedBox(width: 10),
                    Text('Pillmo',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        await context.read<AuthCubit>().logout();
                      },
                      tooltip: 'Cerrar sesión',
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const GlassBackground(),
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 72),
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 84,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(24),
                  blurSigma: 24,
                  child: NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _currentIndex = index),
                    destinations: [
                      const NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Inicio'),
                      const NavigationDestination(
                          icon: Icon(Icons.calendar_month_outlined),
                          selectedIcon: Icon(Icons.calendar_month),
                          label: 'Calendario'),
                      if (isCaregiver)
                        const NavigationDestination(
                            icon: Icon(Icons.people_outline), label: 'Familia'),
                      const NavigationDestination(
                          icon: Icon(Icons.person_outline), label: 'Perfil'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(30),
          tint: AppTheme.coral,
          tintOpacity: .85,
          blurSigma: 18,
          interactive: true,
          semanticLabel: 'Agregar medicamento',
          onTap: () =>
              showMedicationActionSheet(context, userId: widget.userId),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
