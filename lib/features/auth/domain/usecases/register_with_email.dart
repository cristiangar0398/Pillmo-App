import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  const RegisterWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) {
    return _repository.registerWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }
}
