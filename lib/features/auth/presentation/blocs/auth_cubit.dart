import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._registerUseCase,
    this._loginUseCase,
    this._googleSignInUseCase,
    this._localDataSource,
  ) : super(const AuthInitial());

  final RegisterWithEmailUseCase _registerUseCase;
  final LoginWithEmailUseCase _loginUseCase;
  final SignInWithGoogleUseCase _googleSignInUseCase;
  final AuthLocalDataSource _localDataSource;

  Future<void> checkAuthStatus() async {
    final user = await _localDataSource.getUser();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    emit(const AuthLoading());
    final result = await _registerUseCase(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
    _emitResult(result);
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(email: email, password: password);
    _emitResult(result);
  }

  /// Starts (or completes) Google Sign-In. Pass [role] up front on the
  /// registration screen; omit it on login and, if the profile turns out to
  /// be brand-new, this emits [AuthRoleRequired] so the UI can prompt for a
  /// role and call this again with it — Google's account picker won't
  /// reappear since the sign-in already succeeded.
  Future<void> signInWithGoogle({String? role}) async {
    emit(const AuthLoading());
    final result = await _googleSignInUseCase(role: role);
    _emitResult(result);
  }

  void _emitResult(Either<Failure, UserEntity> result) {
    result.fold(
      (failure) => emit(
        failure is RoleRequiredFailure
            ? AuthRoleRequired(failure.message)
            : AuthError(failure.message),
      ),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> logout() async {
    await _localDataSource.deleteUser();
    emit(const Unauthenticated());
  }
}

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final UserEntity user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// A Google Sign-In succeeded against Firebase but the backend has no
/// profile for that identity yet and needs a role to create one.
class AuthRoleRequired extends AuthState {
  const AuthRoleRequired(this.message);

  final String message;
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
