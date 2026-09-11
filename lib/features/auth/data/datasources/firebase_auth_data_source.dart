import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

/// The identity Firebase Auth handed back after a successful sign-in, in the
/// shape the backend's `POST /auth/sync` expects (`firebase_uid` + `email`),
/// plus the provider so the caller can tell a fresh Google Sign-In apart from
/// a traditional email/password one.
class FirebaseAuthCredentialResult {
  const FirebaseAuthCredentialResult({
    required this.firebaseUid,
    required this.email,
    required this.provider,
    this.displayName,
  });

  final String firebaseUid;
  final String email;
  final String provider;
  final String? displayName;
}

abstract interface class FirebaseAuthDataSource {
  Future<FirebaseAuthCredentialResult> registerWithEmail({
    required String email,
    required String password,
  });

  Future<FirebaseAuthCredentialResult> loginWithEmail({
    required String email,
    required String password,
  });

  Future<FirebaseAuthCredentialResult> signInWithGoogle();

  Future<void> signOut();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  FirebaseAuthDataSourceImpl(this._googleSignIn);

  final GoogleSignIn _googleSignIn;

  // `FirebaseAuth.instance` throws if no Firebase App has been initialized
  // (see main.dart's guarded Firebase.initializeApp()). Reading it lazily
  // inside each method — instead of injecting it as a constructor
  // dependency — keeps that failure scoped to an actual sign-in attempt
  // instead of blowing up the whole DI graph the moment AuthCubit is built
  // at app startup (before the user has touched any auth button).
  fb.FirebaseAuth get _firebaseAuth => fb.FirebaseAuth.instance;

  @override
  Future<FirebaseAuthCredentialResult> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _credentialFrom(credential.user, provider: 'password');
  }

  @override
  Future<FirebaseAuthCredentialResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _credentialFrom(credential.user, provider: 'password');
  }

  @override
  Future<FirebaseAuthCredentialResult> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw StateError('El inicio de sesión con Google fue cancelado');
    }
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return _credentialFrom(userCredential.user, provider: 'google.com');
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  FirebaseAuthCredentialResult _credentialFrom(
    fb.User? user, {
    required String provider,
  }) {
    if (user == null || user.email == null) {
      throw StateError('Firebase no devolvió un usuario válido');
    }
    return FirebaseAuthCredentialResult(
      firebaseUid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      provider: provider,
    );
  }
}
