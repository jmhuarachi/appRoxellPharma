class ApiConstants {
  // Para emulador Android:
  //static const String baseUrl = 'http://10.0.2.2:8000/api';
  // con IP Local:
  static const String baseUrl = 'http://192.168.43.89/api';
  //para emulador web:
  //static const String baseUrl = 'http://roxellpharma.test:8000/api';
  
  
  // Endpoints actualizados según tu respuesta JSON
  static const String loginEndpoint = '/v1/auth/login';
  static const String logoutEndpoint = '/v1/auth/logout';
  static const String userEndpoint = '/v1/user';
  
  // Orders Endpoints
  static const String productosEndpoint = '/v1/pedidos';

  // Endpoints adicionales que podrías necesitar
  //static const String productosEndpoint = '/v1/productos';    // Según tu ruta API
  
  // Headers
  static const String acceptHeader = 'Accept';
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  
  // Content Types
  static const String jsonContentType = 'application/json';
}