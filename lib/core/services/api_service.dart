import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roxellpharma/core/costants/api_constants.dart';
import 'package:roxellpharma/core/utils/storage_util.dart';

class ApiService {
  final StorageUtil _storage;
  final http.Client _client;

  ApiService(this._storage, [http.Client? client]) 
    : _client = client ?? http.Client();

  Future<Map<String, dynamic>> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = {
        'Accept': 'application/json',
      };

      if (requiresAuth) {
        final token = await _storage.getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(uri, headers: headers);
          break;
        case 'POST':
          headers['Content-Type'] = 'application/json';
          response = await _client.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          headers['Content-Type'] = 'application/json';
          response = await _client.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Método HTTP no soportado');
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en la solicitud: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Error en la respuesta del servidor');
    }
  }

  void dispose() {
    _client.close();
  }
}