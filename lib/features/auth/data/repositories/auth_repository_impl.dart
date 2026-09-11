import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._firebaseAuthDataSource,
    this._remoteDataSource,
    this._localDataSource,
  );

  final FirebaseAuthDataSource _firebaseAuthDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) {
    return _authenticate(
      () => _firebaseAuthDataSource.registerWithEmail(
        email: email,
        password: password,
      ),
      fullName: fullName,
      role: role,
    );
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => _firebaseAuthDataSource.loginWithEmail(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle({String? role}) {
    return _authenticate(
      () => _firebaseAuthDataSource.signInWithGoogle(),
      role: role,
    );
  }

  Future<Either<Failure, UserEntity>> _authenticate(
    Future<FirebaseAuthCredentialResult> Function() signIn, {
    String? fullName,
    String? role,
  }) async {
    try {
      final credential = await signIn();
      final userModel = await _remoteDataSource.syncUser(
        firebaseUid: credential.firebaseUid,
        email: credential.email,
        fullName: fullName ?? credential.displayName,
        role: role,
        provider: credential.provider,
      );

      await _localDataSource.saveUser(userModel);
      return Right(userModel);
    } on fb.FirebaseAuthException catch (e) {
      return Left(ServerFailure(_firebaseErrorMessage(e)));
    } on DioException catch (e) {
      return Left(_syncFailureFrom(e));
    } on FormatException catch (e) {
      return Left(ServerFailure(e.message));
    } on StateError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo completar la autenticación'));
    }
  }

  Failure _syncFailureFrom(DioException e) {
    final data = e.response?.data;
    final backendMessage = data is Map ? data['error']?.toString() : null;
    final message = backendMessage ?? e.message ?? 'Error del servidor';
    if (e.response?.statusCode == 400 && message.contains('role is required')) {
      return RoleRequiredFailure(message);
    }
    return ServerFailure(message);
  }

  String _firebaseErrorMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Ese correo ya tiene una cuenta. Intenta iniciar sesión.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada.';
      default:
        return e.message ?? 'No se pudo completar la autenticación';
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuthDataSource.signOut();
    } catch (_) {
      // Local session must clear even if Firebase itself is unreachable or
      // unconfigured (see FirebaseAuthDataSourceImpl._firebaseAuth) — the
      // user still expects tapping "logout" to sign them out of the app.
    }
    await _localDataSource.deleteUser();
  }

  @override
  Future<UserModel?> getLocalUser() => _localDataSource.getUser();
}
