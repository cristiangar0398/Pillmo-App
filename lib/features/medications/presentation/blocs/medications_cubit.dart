import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dose_entity.dart';
import '../../domain/entities/prescription_scan_entity.dart';
import '../../domain/usecases/get_medications.dart';

class MedicationCubit extends Cubit<MedicationState> {
  MedicationCubit(
    this._getTodayTimelineUseCase,
    this._confirmDoseUseCase,
    this._scanPrescriptionUseCase,
  ) : super(const MedicationLoading());

  final GetTodayTimelineUseCase _getTodayTimelineUseCase;
  final ConfirmDoseUseCase _confirmDoseUseCase;
  final ScanPrescriptionUseCase _scanPrescriptionUseCase;

  Future<void> loadTodayTimeline(String userId) async {
    emit(const MedicationLoading());

    final result = await _getTodayTimelineUseCase(userId);
    result.fold(
      (failure) => emit(MedicationError(failure.message)),
      (doses) => emit(MedicationLoaded(doses)),
    );
  }

  Future<void> confirmDose(String userId, String doseId) async {
    final currentState = state;
    if (currentState is! MedicationLoaded) {
      return;
    }

    final result = await _confirmDoseUseCase(doseId);
    result.fold(
      (failure) => emit(MedicationError(failure.message)),
      (_) => loadTodayTimeline(userId),
    );
  }

  Future<void> addManualMedication({
    required String userId,
    required String medicineName,
    required String dosage,
    required TimeOfDay time,
  }) async {
    final name = medicineName.trim();
    if (name.isEmpty || dosage.trim().isEmpty) {
      emit(const MedicationError('Completa el nombre y la dosis del medicamento.'));
      return;
    }

    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final newDose = DoseEntity(
      id: 'manual-${DateTime.now().millisecondsSinceEpoch}',
      medicationName: name,
      dosage: dosage.trim(),
      scheduledTime: scheduledDate,
      status: 'PENDING',
    );

    final currentState = state;
    if (currentState is MedicationLoaded) {
      emit(MedicationLoaded([...currentState.doses, newDose]));
    } else {
      emit(MedicationLoaded([newDose]));
    }

    await loadTodayTimeline(userId);
  }

  Future<void> scanPrescription({
    required String userId,
    required String imagePath,
  }) async {
    emit(const MedicationLoading());

    final result = await _scanPrescriptionUseCase(
      userId: userId,
      imagePath: imagePath,
    );

    result.fold(
      (failure) => emit(MedicationError(failure.message)),
      (scan) => emit(PrescriptionScanned(scan)),
    );
  }
}

sealed class MedicationState {
  const MedicationState();
}

class MedicationLoading extends MedicationState {
  const MedicationLoading();
}

class MedicationLoaded extends MedicationState {
  const MedicationLoaded(this.doses);

  final List<DoseEntity> doses;
}

class PrescriptionScanned extends MedicationState {
  const PrescriptionScanned(this.scan);

  final PrescriptionScanEntity scan;
}

class MedicationError extends MedicationState {
  const MedicationError(this.message);

  final String message;
}
