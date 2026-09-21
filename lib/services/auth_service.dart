import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Currently logged-in user
  User? get currentUser => _auth.currentUser;

  // Listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a new user
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login existing user
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> checkEmailVerification() async {
  final user = _auth.currentUser;

  if (user == null) {
    return false;
  }

  await user.reload();

  return _auth.currentUser?.emailVerified ?? false;
}

Future<User?> reloadCurrentUser() async {
  final user = _auth.currentUser;

  if (user == null) {
    return null;
  }

  await user.reload();

  return _auth.currentUser;
}
}