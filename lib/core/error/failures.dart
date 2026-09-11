abstract class Failure {
  const Failure(this.message);
  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local']);
}

/// Raised when the backend rejects an /auth/sync call because it belongs to a
/// brand-new profile that still needs a role (e.g. a first-time Google
/// Sign-In from the login screen, which never asked for one). The UI reacts
/// by prompting a role picker and resubmitting instead of showing a plain error.
class RoleRequiredFailure extends Failure {
  const RoleRequiredFailure(
      [super.message = 'Selecciona un rol para completar tu registro']);
}
