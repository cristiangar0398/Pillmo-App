import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/auth_local_data_source.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sync_user.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._syncUserUseCase, this._localDataSource) : super(const AuthInitial());

  final SyncUserUseCase _syncUserUseCase;
  final AuthLocalDataSource _localDataSource;

  Future<void> checkAuthStatus() async {
    final user = await _localDataSource.getUser();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> syncUser({
    required String firebaseUid,
    required String email,
    String? fullName,
    String? role,
  }) async {
    emit(const AuthLoading());

    final result = await _syncUserUseCase(
      firebaseUid: firebaseUid,
      email: email,
      fullName: fullName,
      role: role,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
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

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
