import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/config/app_theme.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/widgets/staggered_fade_in.dart';
import '../../../../core/widgets/status_message_card.dart';
import '../../../medications/presentation/widgets/medication_tile.dart';
import '../blocs/calendar_cubit.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.userId});

  final String userId;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CalendarCubit>().loadMonth(widget.userId, DateTime.now());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            'Calendario',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: BlocBuilder<CalendarCubit, CalendarState>(
            builder: (context, state) {
              if (state is CalendarLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CalendarError) {
                return ResponsiveCenter(
                  child: StatusMessageCard(
                    message: state.message,
                    onRetry: () => context
                        .read<CalendarCubit>()
                        .loadMonth(widget.userId, DateTime.now()),
                  ),
                );
              }

              if (state is CalendarLoaded) {
                final dosesOfSelectedDay = state.dosesFor(state.selectedDay);
                final glass = context.glass;
                return ResponsiveCenter(
                  child: Column(
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: TableCalendar<Object>(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2035, 12, 31),
                          focusedDay: state.focusedMonth,
                          currentDay: DateTime.now(),
                          selectedDayPredicate: (day) =>
                              isSameDay(day, state.selectedDay),
                          eventLoader: state.dosesFor,
                          onDaySelected: (selectedDay, _) => context
                              .read<CalendarCubit>()
                              .selectDay(selectedDay),
                          onPageChanged: (focusedMonth) => context
                              .read<CalendarCubit>()
                              .loadMonth(widget.userId, focusedMonth),
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Mes',
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                                color: glass.ink,
                                fontSize: 17,
                                fontWeight: FontWeight.w800),
                            leftChevronIcon:
                                Icon(Icons.chevron_left, color: glass.ink),
                            rightChevronIcon:
                                Icon(Icons.chevron_right, color: glass.ink),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                                color: glass.muted,
                                fontWeight: FontWeight.w700),
                            weekendStyle: TextStyle(
                                color: glass.muted,
                                fontWeight: FontWeight.w700),
                          ),
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: TextStyle(color: glass.ink),
                            weekendTextStyle: TextStyle(color: glass.ink),
                            outsideTextStyle: TextStyle(color: glass.muted),
                            todayTextStyle: TextStyle(
                                color: glass.ink, fontWeight: FontWeight.w800),
                            selectedTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                            todayDecoration: BoxDecoration(
                              color: glass.mintPale,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: AppTheme.mint,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: AppTheme.coral,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: dosesOfSelectedDay.isEmpty
                            ? const _EmptyDayState()
                            : RefreshIndicator(
                                onRefresh: () => context
                                    .read<CalendarCubit>()
                                    .loadMonth(
                                        widget.userId, state.focusedMonth),
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  itemCount: dosesOfSelectedDay.length,
                                  itemBuilder: (context, index) {
                                    final dose = dosesOfSelectedDay[index];
                                    return StaggeredFadeIn(
                                      index: index,
                                      child: DoseCard(
                                        key: ValueKey(dose.id),
                                        dose: dose,
                                        onConfirm: () => context
                                            .read<CalendarCubit>()
                                            .confirmDose(dose.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.event_available_outlined, size: 48),
            SizedBox(height: 12),
            Text('No hay tomas programadas este día',
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
