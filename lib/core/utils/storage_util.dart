// lib/core/utils/storage_util.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roxellpharma/features/auth/domain/models/user_model.dart';

class StorageUtil {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences _prefs;

  StorageUtil(SharedPreferences prefs) : _prefs = prefs;

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> saveUser(User user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _prefs.setString('user_data', userJson);
    } catch (e) {
      print('Error al guardar usuario: $e');
      throw e;
    }
  }

  Future<void> clearCorruptedData() async {
    await _prefs.remove('user_data');
    await _secureStorage.delete(key: 'auth_token');
  }

  Future<User?> getUser() async {
    try {
      final userData = _prefs.getString('user_data');
      if (userData != null) {
        // Primero verifica si es un JSON válido
        if (userData.trim().startsWith('{') && userData.trim().endsWith('}')) {
          return User.fromJson(json.decode(userData));
        } else {
          // Intenta corregir el formato manualmente
          final fixedJson = userData
              .replaceAll('{', '{"')
              .replaceAll(': ', '": "')
              .replaceAll(', ', '", "')
              .replaceAll('}', '"}');
          return User.fromJson(json.decode(fixedJson));
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      await clearAll(); // Limpia datos corruptos
      return null;
    }
  }

  Future<void> clearAll() async {
    await _secureStorage.delete(key: 'auth_token');
    await _prefs.remove('user_data');
  }
}
