import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../medications/domain/entities/dose_entity.dart';
import '../../../medications/domain/usecases/get_medications.dart';

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit(
    this._getTimelineRangeUseCase,
    this._confirmDoseUseCase,
  ) : super(const CalendarLoading());

  final GetTimelineRangeUseCase _getTimelineRangeUseCase;
  final ConfirmDoseUseCase _confirmDoseUseCase;

  String? _userId;
  DateTime _focusedMonth = _dateOnly(DateTime.now());

  Future<void> loadMonth(String userId, DateTime month) async {
    _userId = userId;
    _focusedMonth = DateTime(month.year, month.month);
    emit(const CalendarLoading());

    final firstDay = DateTime(month.year, month.month);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final result = await _getTimelineRangeUseCase(
      userId: userId,
      startDate: firstDay,
      endDate: lastDay,
    );

    result.fold(
      (failure) => emit(CalendarError(failure.message)),
      (doses) {
        final dosesByDay = <DateTime, List<DoseEntity>>{};
        for (final dose in doses) {
          final day = _dateOnly(dose.scheduledTime.toLocal());
          dosesByDay.putIfAbsent(day, () => []).add(dose);
        }
        final today = _dateOnly(DateTime.now());
        final selectedDay =
            today.year == month.year && today.month == month.month
                ? today
                : firstDay;
        emit(CalendarLoaded(
          dosesByDay: dosesByDay,
          focusedMonth: _focusedMonth,
          selectedDay: selectedDay,
        ));
      },
    );
  }

  void selectDay(DateTime day) {
    final currentState = state;
    if (currentState is! CalendarLoaded) {
      return;
    }
    emit(currentState.copyWith(selectedDay: _dateOnly(day)));
  }

  Future<void> confirmDose(String doseId) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    final result = await _confirmDoseUseCase(doseId);
    result.fold(
      (failure) => emit(CalendarError(failure.message)),
      (_) => loadMonth(userId, _focusedMonth),
    );
  }
}

sealed class CalendarState {
  const CalendarState();
}

class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

class CalendarLoaded extends CalendarState {
  const CalendarLoaded({
    required this.dosesByDay,
    required this.focusedMonth,
    required this.selectedDay,
  });

  final Map<DateTime, List<DoseEntity>> dosesByDay;
  final DateTime focusedMonth;
  final DateTime selectedDay;

  List<DoseEntity> dosesFor(DateTime day) =>
      dosesByDay[_dateOnly(day)] ?? const [];

  CalendarLoaded copyWith({DateTime? selectedDay}) => CalendarLoaded(
        dosesByDay: dosesByDay,
        focusedMonth: focusedMonth,
        selectedDay: selectedDay ?? this.selectedDay,
      );
}

class CalendarError extends CalendarState {
  const CalendarError(this.message);

  final String message;
}
