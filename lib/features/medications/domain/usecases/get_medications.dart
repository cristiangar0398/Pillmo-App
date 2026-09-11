import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/dose_entity.dart';
import '../entities/prescription_scan_entity.dart';
import '../repositories/medications_repository.dart';

class GetTodayTimelineUseCase {
  const GetTodayTimelineUseCase(this.repository);

  final MedicationsRepository repository;

  Future<Either<Failure, List<DoseEntity>>> call(String userId) {
    // The timeline API must receive the database UUID returned by auth sync,
    // never the Firebase UID used only for authentication.
    final databaseUserId = userId.trim();
    return repository.getTodayTimeline(databaseUserId);
  }
}

class GetTimelineRangeUseCase {
  const GetTimelineRangeUseCase(this.repository);

  final MedicationsRepository repository;

  Future<Either<Failure, List<DoseEntity>>> call({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getTimeline(
      userId: userId.trim(),
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class CreateMedicationUseCase {
  const CreateMedicationUseCase(this.repository);

  final MedicationsRepository repository;

  Future<Either<Failure, void>> call({
    required String userId,
    required String medicineName,
    required String dosage,
    required String frequency,
    required String scheduledTime,
    required String startDate,
    String? endDate,
    String? instructions,
  }) {
    return repository.createMedication(
      userId: userId.trim(),
      medicineName: medicineName.trim(),
      dosage: dosage.trim(),
      frequency: frequency.trim(),
      scheduledTime: scheduledTime,
      startDate: startDate,
      endDate: endDate,
      instructions: instructions,
    );
  }
}

class ConfirmDoseUseCase {
  const ConfirmDoseUseCase(this.repository);

  final MedicationsRepository repository;

  Future<Either<Failure, void>> call(String doseId) =>
      repository.confirmDose(doseId);
}

class ScanPrescriptionUseCase {
  const ScanPrescriptionUseCase(this.repository);

  final MedicationsRepository repository;

  Future<Either<Failure, PrescriptionScanEntity>> call({
    required String userId,
    required String imagePath,
  }) {
    return repository.scanPrescription(
      userId: userId,
      imagePath: imagePath,
    );
  }
}
