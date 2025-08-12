// lib/features/auth/domain/repositories/auth_repository_impl.dart
import 'package:roxellpharma/core/services/auth_service.dart';
import 'package:roxellpharma/features/auth/domain/models/user_model.dart';
import 'package:roxellpharma/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<User?> login(String email, String password) async {
    return _authService.login(email, password);
  }

  @override
  Future<void> logout() async {
    return _authService.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return _authService.getCurrentUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return _authService.isLoggedIn();
  }
}