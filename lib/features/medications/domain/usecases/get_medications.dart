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
