import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/dose_entity.dart';
import '../entities/prescription_scan_entity.dart';

abstract interface class MedicationsRepository {
  Future<Either<Failure, List<DoseEntity>>> getTodayTimeline(String userId);
  Future<Either<Failure, void>> confirmDose(String doseId);
  Future<Either<Failure, PrescriptionScanEntity>> scanPrescription({
    required String userId,
    required String imagePath,
  });
}
