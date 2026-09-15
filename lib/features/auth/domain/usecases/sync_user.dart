import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SyncUserUseCase {
  const SyncUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String firebaseUid,
    required String email,
    String? fullName,
    String? role,
  }) {
    return _repository.syncUser(
      firebaseUid: firebaseUid,
      email: email,
      fullName: fullName,
      role: role,
    );
  }
}
