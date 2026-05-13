import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/signin_with_google_usecase.dart';
import '../../../domain/usecases/auth/signin_anonymously_usecase.dart';
import '../../../domain/usecases/auth/send_password_reset_usecase.dart';

enum LoginStatus { idle, loading, success, error }

/// Refactored LoginProvider using Clean Architecture Use Cases
class LoginProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignInWithGoogleUseCase _googleUseCase;
  final SignInAnonymouslyUseCase _guestUseCase;
  final SendPasswordResetUseCase _resetUseCase;
  final SharedPreferences _prefs;

  LoginProvider(
    this._loginUseCase,
    this._googleUseCase,
    this._guestUseCase,
    this._resetUseCase,
    this._prefs,
  );

  String email = '';
  String password = '';
  LoginStatus status = LoginStatus.idle;
  String? errorMessage;
  bool obscurePassword = true;

  void setEmail(String v) {
    email = v;
    notifyListeners();
  }

  void setPassword(String v) {
    password = v;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> signIn(VoidCallback onSuccess) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Please fill in all fields.';
      notifyListeners();
      return;
    }
    status = LoginStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _loginUseCase(email, password);
    
    if (result.isSuccess) {
      status = LoginStatus.success;
      notifyListeners();
      onSuccess();
    } else {
      status = LoginStatus.error;
      errorMessage = _mapFailure(result.failure!.message);
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle(VoidCallback onSuccess) async {
    status = LoginStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _googleUseCase();
    
    if (result.isSuccess) {
      status = LoginStatus.success;
      notifyListeners();
      onSuccess();
    } else {
      status = LoginStatus.error;
      errorMessage = 'Google sign-in failed. Please try again.';
      notifyListeners();
    }
  }

  Future<void> signInAsGuest(VoidCallback onSuccess) async {
    status = LoginStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _guestUseCase();
    
    if (result.isSuccess) {
      status = LoginStatus.success;
      notifyListeners();
      onSuccess();
    } else {
      status = LoginStatus.error;
      errorMessage = 'Guest sign-in failed.';
      notifyListeners();
    }
  }

  Future<void> sendPasswordReset() async {
    if (email.isEmpty) {
      errorMessage = 'Enter your email to reset your password.';
      notifyListeners();
      return;
    }
    
    final result = await _resetUseCase(email);
    if (result.isSuccess) {
      errorMessage = null;
      notifyListeners();
    } else {
      errorMessage = 'Failed to send reset email.';
      notifyListeners();
    }
  }

  String _mapFailure(String e) {
    if (e.contains('wrong-password') || e.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (e.contains('user-not-found')) return 'No account found with that email.';
    if (e.contains('network-request-failed')) return 'No internet connection.';
    return 'Sign-in failed. Please try again.';
  }
}

