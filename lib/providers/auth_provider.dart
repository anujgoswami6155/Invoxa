import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _firebaseUser;
  UserModel? _user;

  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _firebaseUser != null;

  Stream<User?> get userChanges => _authService.userChanges;

  // Constructor, initializes the AuthProvider and listens to authentication state changes
  AuthProvider() {
    _firebaseUser = _authService.currentUser;

    _authService.userChanges.listen(_onAuthStateChanged);
  }

  // Handle authentication state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;

    if (firebaseUser != null) {
      _user = await _userService.getUser(firebaseUser.uid);
    } else {
      _user = null;
    }

    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _authService.register(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        _errorMessage = 'Registration failed. Please try again.';
        return false;
      }

      final user = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _userService.createUser(user);

      _firebaseUser = firebaseUser;
      _user = user;

      await _authService.sendEmailVerification();

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _authService.login(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;

      if (_firebaseUser != null) {
        _user = await _userService.getUser(
          _firebaseUser!.uid,
        );

        if (_user == null) {
          _errorMessage =
              'User profile not found. Please contact support.';
          return false;
        }
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();

      _firebaseUser = null;
      _user = null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendEmailVerification();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkEmailVerification() async {
    _setLoading(true);
    _clearError();

    try {
      final verified = await _authService.checkEmailVerification();

      if (verified) {
        _firebaseUser = _authService.currentUser;

        if (_firebaseUser != null) {
          _user = await _userService.getUser(
            _firebaseUser!.uid,
          );
        }

        notifyListeners();
      }

      return verified;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your connection.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
