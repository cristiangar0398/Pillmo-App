import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dose_entity.dart';
import '../../domain/entities/prescription_scan_entity.dart';
import '../../domain/usecases/get_medications.dart';

class MedicationCubit extends Cubit<MedicationState> {
  MedicationCubit(
    this._getTodayTimelineUseCase,
    this._createMedicationUseCase,
    this._confirmDoseUseCase,
    this._scanPrescriptionUseCase,
  ) : super(const MedicationLoading());

  final GetTodayTimelineUseCase _getTodayTimelineUseCase;
  final CreateMedicationUseCase _createMedicationUseCase;
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

  Future<bool> addManualMedication({
    required String userId,
    required String medicineName,
    required String dosage,
    required TimeOfDay time,
    String frequency = 'Cada 24 horas',
    String? endDate,
    String? instructions,
  }) async {
    final name = medicineName.trim();
    if (name.isEmpty || dosage.trim().isEmpty) {
      emit(const MedicationError(
          'Completa el nombre y la dosis del medicamento.'));
      return false;
    }

    final now = DateTime.now();
    final scheduledTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final startDate =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final result = await _createMedicationUseCase(
      userId: userId,
      medicineName: name,
      dosage: dosage,
      frequency: frequency,
      scheduledTime: scheduledTime,
      startDate: startDate,
      endDate: endDate,
      instructions: instructions,
    );
    return result.fold(
      (failure) {
        emit(MedicationError(failure.message));
        return false;
      },
      (_) async {
        await loadTodayTimeline(userId);
        return true;
      },
    );
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
