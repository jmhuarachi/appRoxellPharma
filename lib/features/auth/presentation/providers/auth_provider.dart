// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:roxellpharma/features/auth/domain/models/user_model.dart';
import 'package:roxellpharma/features/auth/domain/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authRepository);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authRepository.login(email, password);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // En auth_provider.dart
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepository.logout();
      _user = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    _user = await _authRepository.getCurrentUser();
    notifyListeners();
  }
}
