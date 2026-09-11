import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/dose_entity.dart';
import '../entities/prescription_scan_entity.dart';

abstract interface class MedicationsRepository {
  Future<Either<Failure, List<DoseEntity>>> getTodayTimeline(String userId);
  Future<Either<Failure, List<DoseEntity>>> getTimeline({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<Either<Failure, void>> createMedication({
    required String userId,
    required String medicineName,
    required String dosage,
    required String frequency,
    required String scheduledTime,
    required String startDate,
    String? endDate,
    String? instructions,
  });
  Future<Either<Failure, void>> confirmDose(String doseId);
  Future<Either<Failure, PrescriptionScanEntity>> scanPrescription({
    required String userId,
    required String imagePath,
  });
}
