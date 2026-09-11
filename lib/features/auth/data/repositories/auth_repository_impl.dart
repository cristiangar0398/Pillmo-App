import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, UserEntity>> syncUser({
    required String firebaseUid,
    required String email,
    String? fullName,
    String? role,
  }) async {
    try {
      final userModel = await _remoteDataSource.syncUser(
        firebaseUid: firebaseUid,
        email: email,
        fullName: fullName,
        role: role,
      );

      await _localDataSource.saveUser(userModel);
      return Right(userModel);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ?? e.message ?? 'Error del servidor'
          : e.message ?? 'Error del servidor';
      return Left(ServerFailure(message));
    } on FormatException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo sincronizar el usuario'));
    }
  }

  @override
  Future<void> logout() async {
    await _localDataSource.deleteUser();
  }

  Future<UserModel?> getLocalUser() => _localDataSource.getUser();
}
