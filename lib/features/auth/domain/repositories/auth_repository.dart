import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  /// First-time registration with email/password. [fullName] and [role] are
  /// mandatory here since the backend has no existing profile to fall back on.
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  /// Recurring login with email/password for an already-registered user.
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Signs in (or transparently registers) with Google. [role] is only
  /// required when this turns out to be a brand-new profile — omit it for a
  /// login attempt and handle a [RoleRequiredFailure] by asking the user to
  /// pick one and retrying.
  Future<Either<Failure, UserEntity>> signInWithGoogle({String? role});

  Future<void> logout();
  Future<UserEntity?> getLocalUser();
}
