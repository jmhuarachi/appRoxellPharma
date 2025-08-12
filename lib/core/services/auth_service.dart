// lib/core/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:roxellpharma/core/costants/api_constants.dart';

import 'package:roxellpharma/core/utils/storage_util.dart';
import 'package:roxellpharma/features/auth/domain/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final StorageUtil _storage;

  AuthService(SharedPreferences prefs) : _storage = StorageUtil(prefs);

  Future<User?> login(String email, String password) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}';
      debugPrint('Attempting to login at: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        final token = data['token'];

        await _storage.saveToken(token);
        await _storage.saveUser(user);

        return user;
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception(
        'Error de conexión. Verifica tu consola para más detalles',
      );
    }
  }

  Future<void> logout() async {
    try {
      final token = await _storage.getToken();

      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/mobile/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      await _storage.clearAll();
    } catch (e) {
      debugPrint('Logout error: $e');
      throw Exception('Error al cerrar sesión');
    }
  }

  Future<User?> getCurrentUser() async {
    final user = await _storage.getUser();
    return user;
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }
}
