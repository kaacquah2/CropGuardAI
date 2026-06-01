import 'package:flutter/material.dart';
import '../../../core/utils/email_validator.dart';
import '../../../domain/usecases/auth/register_usecase.dart';

enum RegisterStatus { idle, loading, success, error }

/// Refactored RegisterProvider using Clean Architecture
class RegisterProvider extends ChangeNotifier {
  final RegisterUseCase _registerUseCase;

  RegisterProvider(this._registerUseCase);

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool termsAccepted = false;
  RegisterStatus status = RegisterStatus.idle;
  String? errorMessage;
  bool obscurePassword = true;

  void setName(String v) { name = v; notifyListeners(); }
  void setEmail(String v) { email = v; notifyListeners(); }
  void setPassword(String v) { password = v; notifyListeners(); }
  void setConfirmPassword(String v) { confirmPassword = v; notifyListeners(); }
  void setTermsAccepted(bool v) { termsAccepted = v; notifyListeners(); }
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  int get passwordStrength {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[^a-zA-Z0-9]'));
    if (password.length >= 12 && hasDigit && hasSpecial) return 4;
    if (password.length >= 8 && hasDigit) return 3;
    if (password.length >= 9 && hasDigit && hasSpecial) return 3;
    return 2;
  }

  Future<void> register(VoidCallback onSuccess) async {
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      errorMessage = 'Please fill in all fields.';
      notifyListeners();
      return;
    }
    if (!EmailValidator.isValid(email)) {
      errorMessage = 'Please enter a valid email address.';
      notifyListeners();
      return;
    }
    if (password != confirmPassword) {
      errorMessage = 'Passwords do not match.';
      notifyListeners();
      return;
    }
    if (!termsAccepted) {
      errorMessage = 'Please accept the terms and privacy policy.';
      notifyListeners();
      return;
    }
    if (password.length < 6) {
      errorMessage = 'Password must be at least 6 characters.';
      notifyListeners();
      return;
    }
    status = RegisterStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _registerUseCase(email: email, password: password, name: name);
    
    if (result.isSuccess) {
      status = RegisterStatus.success;
      notifyListeners();
      onSuccess();
    } else {
      status = RegisterStatus.error;
      errorMessage = _mapError(result.failure!.message);
      notifyListeners();
    }
  }

  String _mapError(String e) {
    if (e.contains('email-already-in-use')) return 'An account already exists with that email.';
    if (e.contains('weak-password')) return 'Password is too weak.';
    if (e.contains('network-request-failed')) return 'No internet connection.';
    return 'Registration failed. Please try again.';
  }
}

