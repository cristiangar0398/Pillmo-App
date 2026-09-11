import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dose_entity.dart';
import '../../domain/entities/prescription_scan_entity.dart';
import '../../domain/repositories/medications_repository.dart';
import '../datasources/medications_remote_data_source.dart';

class MedicationRepositoryImpl implements MedicationsRepository {
  MedicationRepositoryImpl(this._remoteDataSource);

  final MedicationRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<DoseEntity>>> getTodayTimeline(
      String userId) async {
    try {
      final doses = await _remoteDataSource.getTodayTimeline(userId);
      return Right(doses);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ??
              e.message ??
              'Error del servidor'
          : e.message ?? 'Error del servidor';
      return Left(ServerFailure(message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo obtener la línea del día'));
    }
  }

  @override
  Future<Either<Failure, List<DoseEntity>>> getTimeline({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final doses = await _remoteDataSource.getTimeline(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(doses);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ??
              e.message ??
              'Error del servidor'
          : e.message ?? 'Error del servidor';
      return Left(ServerFailure(message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo obtener el calendario'));
    }
  }

  @override
  Future<Either<Failure, void>> createMedication({
    required String userId,
    required String medicineName,
    required String dosage,
    required String frequency,
    required String scheduledTime,
    required String startDate,
    String? endDate,
    String? instructions,
  }) async {
    try {
      await _remoteDataSource.createMedication(
        userId: userId,
        medicineName: medicineName,
        dosage: dosage,
        frequency: frequency,
        scheduledTime: scheduledTime,
        startDate: startDate,
        endDate: endDate,
        instructions: instructions,
      );
      return const Right(null);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ??
              e.message ??
              'Error del servidor'
          : e.message ?? 'Error del servidor';
      return Left(ServerFailure(message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo guardar el medicamento'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmDose(String doseId) async {
    try {
      await _remoteDataSource.confirmDose(doseId);
      return const Right(null);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ??
              e.message ??
              'Error del servidor'
          : e.message ?? 'Error del servidor';
      return Left(ServerFailure(message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo confirmar la dosis'));
    }
  }

  @override
  Future<Either<Failure, PrescriptionScanEntity>> scanPrescription({
    required String userId,
    required String imagePath,
  }) async {
    try {
      final scan = await _remoteDataSource.scanPrescription(
        userId: userId,
        imagePath: imagePath,
      );
      return Right(scan);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ??
              e.message ??
              'Error del servidor'
          : e.message ?? 'Error del servidor';
      return Left(ServerFailure(message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo procesar la receta'));
    }
  }
}
