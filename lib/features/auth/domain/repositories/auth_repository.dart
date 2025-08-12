// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:roxellpharma/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
}