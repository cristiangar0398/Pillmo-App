import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> syncUser({
    required String firebaseUid,
    required String email,
    String? fullName,
    String? role,
  });

  Future<void> logout();
  Future<UserEntity?> getLocalUser();
}
