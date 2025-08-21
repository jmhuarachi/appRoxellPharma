// lib/features/dashboard/orders/presentation/providers/orders_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:roxellpharma/core/costants/api_constants.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';
import 'package:roxellpharma/core/utils/storage_util.dart';
import 'package:roxellpharma/features/auth/domain/models/user_model.dart';

class OrderItem {
  final int id;
  final String orderNumber;
  final int clienteId;
  final String clienteNombre;
  final String clienteNit;
  final int sucursalId;
  final String sucursalNombre;
  final int? vendedorId;
  final String? vendedorNombre;
  final DateTime fechaPedido;
  final DateTime? fechaEntrega;
  final String? horaEntregaEstimada;
  final String estado;
  final String metodoPago;
  final int? plazoCredito;
  final String direccionEntrega;
  final double montoTotalFinal;
  final String? notasCliente;
  final List<OrderProduct> productos;

  OrderItem({
    required this.id,
    required this.orderNumber,
    required this.clienteId,
    required this.clienteNombre,
    required this.clienteNit,
    required this.sucursalId,
    required this.sucursalNombre,
    this.vendedorId,
    this.vendedorNombre,
    required this.fechaPedido,
    this.fechaEntrega,
    this.horaEntregaEstimada,
    required this.estado,
    required this.metodoPago,
    this.plazoCredito,
    required this.direccionEntrega,
    required this.montoTotalFinal,
    this.notasCliente,
    required this.productos,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderNumber: json['numero_pedido'],
      clienteId: json['cliente_id'],
      clienteNombre: json['cliente_nombre'],
      clienteNit: json['cliente_nit'],
      sucursalId: json['sucursal_id'],
      sucursalNombre: json['sucursal_nombre'],
      vendedorId: json['vendedor_id'],
      vendedorNombre: json['vendedor_nombre'],
      fechaPedido: DateTime.parse(json['fecha_pedido']),
      fechaEntrega: json['fecha_entrega'] != null
          ? DateTime.parse(json['fecha_entrega'])
          : null,
      horaEntregaEstimada: json['hora_entrega_estimada'],
      estado: json['estado'],
      metodoPago: json['metodo_pago'],
      plazoCredito: json['plazo_credito'],
      direccionEntrega: json['direccion_entrega'],
      montoTotalFinal: json['monto_total_final'].toDouble(),
      notasCliente: json['notas_cliente'],
      productos: (json['productos'] as List)
          .map((e) => OrderProduct.fromJson(e))
          .toList(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero_pedido': orderNumber,
      'cliente_id': clienteId,
      'cliente_nombre': clienteNombre,
      'cliente_nit': clienteNit,
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'vendedor_id': vendedorId,
      'vendedor_nombre': vendedorNombre,
      'fecha_pedido': fechaPedido.toIso8601String(),
      'fecha_entrega': fechaEntrega?.toIso8601String(),
      'hora_entrega_estimada': horaEntregaEstimada,
      'estado': estado,
      'metodo_pago': metodoPago,
      'plazo_credito': plazoCredito,
      'direccion_entrega': direccionEntrega,
      'monto_total_final': montoTotalFinal,
      'notas_cliente': notasCliente,
      'productos': productos.map((p) => p.toMap()).toList(),
    };
  }
}

class OrderProduct {
  final int id;
  final int productoId;
  final String nombre;
  final String presentacion;
  final int cantidad;
  final double precioUnitario;
  final String? tipoDescuento;
  final double? valorDescuento;
  final double subtotal;

  OrderProduct({
    required this.id,
    required this.productoId,
    required this.nombre,
    required this.presentacion,
    required this.cantidad,
    required this.precioUnitario,
    this.tipoDescuento,
    this.valorDescuento,
    required this.subtotal,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'],
      productoId: json['producto_id'],
      nombre: json['nombre'],
      presentacion: json['presentacion'],
      cantidad: json['cantidad'],
      precioUnitario: json['precio_unitario'].toDouble(),
      tipoDescuento: json['tipo_descuento'],
      valorDescuento: json['valor_descuento']?.toDouble(),
      subtotal: json['subtotal'].toDouble(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'nombre': nombre,
      'presentacion': presentacion,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'tipo_descuento': tipoDescuento,
      'valor_descuento': valorDescuento,
      'subtotal': subtotal,
    };
  }
}

class Cliente {
  final int id;
  final String nombre;
  final String nit;

  Cliente({required this.id, required this.nombre, required this.nit});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(id: json['id'], nombre: json['nombre'], nit: json['nit']);
  }
}

class ProductoDisponiblePedido {
  final int id;
  final String nombre;
  final String presentacion;
  final int stock;
  final double precioContado;
  final double precioCredito;

  ProductoDisponiblePedido({
    required this.id,
    required this.nombre,
    required this.presentacion,
    required this.stock,
    required this.precioContado,
    required this.precioCredito,
  });

  factory ProductoDisponiblePedido.fromJson(Map<String, dynamic> json) {
    return ProductoDisponiblePedido(
      id: json['id'],
      nombre: json['nombre'],
      presentacion: json['presentacion'],
      stock: json['stock'],
      precioContado: json['precio_contado'].toDouble(),
      precioCredito: json['precio_credito'].toDouble(),
    );
  }
}

class OrdersProvider with ChangeNotifier {
  final StorageUtil _storage;
  final http.Client _client;

  List<OrderItem> _orders = [];
  List<Cliente> _clientesDisponibles = [];
  List<ProductoDisponiblePedido> _productosDisponibles = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedStatus = 'todos';
  String _selectedPaymentMethod = 'todos';
  String _selectedDateRange = 'todos';
  String _sortField = 'fecha_pedido';
  String _sortDirection = 'desc';
  int _currentPage = 1;
  int _totalItems = 0;
  int _itemsPerPage = 10;

  String get selectedStatus => _selectedStatus;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  String get selectedDateRange => _selectedDateRange;
  String get sortField => _sortField;
  String get sortDirection => _sortDirection;
  String get searchQuery => _searchQuery;

  OrdersProvider(this._storage, [http.Client? client])
    : _client = client ?? http.Client();

  List<OrderItem> get orders => _orders;
  List<Cliente> get clientesDisponibles => _clientesDisponibles;
  List<ProductoDisponiblePedido> get productosDisponibles =>
      _productosDisponibles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalItems => _totalItems;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  Future<void> loadOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      final user = await _storage.getUser();

      if (token == null || user == null) {
        throw Exception('No autenticado - Por favor inicie sesión nuevamente');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/v1/pedidos?'
        'page=$_currentPage'
        '&per_page=$_itemsPerPage'
        '&search=$_searchQuery'
        '&estado=$_selectedStatus'
        '&metodo_pago=$_selectedPaymentMethod'
        '&rango_fechas=$_selectedDateRange'
        '&sort_field=$_sortField'
        '&sort_direction=$_sortDirection',
      );

      final response = await _client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        _orders = (responseData['data'] as List)
            .map((item) => OrderItem.fromJson(item))
            .toList();

        _totalItems = responseData['total'];
        _currentPage = responseData['current_page'];
        _itemsPerPage = responseData['per_page'];

        _error = null;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada - Por favor inicie sesión nuevamente');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al cargar los pedidos');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClientesDisponibles(String search) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/v1/pedidos/clientes-disponibles?search=$search',
      );

      final response = await _client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _clientesDisponibles = (responseData['data'] as List)
            .map((item) => Cliente.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Error al cargar clientes disponibles: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductosDisponibles(String search, int sucursalId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/v1/pedidos/productos-disponibles?'
        'search=$search'
        '&sucursal_id=$sucursalId',
      );

      final response = await _client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _productosDisponibles = (responseData['data'] as List)
            .map((item) => ProductoDisponiblePedido.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Error al cargar productos disponibles: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse('${ApiConstants.baseUrl}/v1/pedidos');

      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        await loadOrders();
        _error = null;
      } else {
        throw Exception('Error al crear pedido: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse('${ApiConstants.baseUrl}/v1/pedidos/$id');

      final response = await _client.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar pedido: ${response.statusCode}');
      }

      await loadOrders();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(int id, String status, {String? notas}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse('${ApiConstants.baseUrl}/v1/pedidos/$id/estado');

      final response = await _client.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'estado': status, 'notas': notas}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al actualizar estado del pedido: ${response.statusCode}',
        );
      }

      await loadOrders();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse('${ApiConstants.baseUrl}/v1/pedidos/$id');

      final response = await _client.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar pedido: ${response.statusCode}');
      }

      await loadOrders();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();
  }

  void setStatus(String status) {
    _selectedStatus = status;
    _currentPage = 1;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    _currentPage = 1;
    notifyListeners();
  }

  void setDateRange(String range) {
    _selectedDateRange = range;
    _currentPage = 1;
    notifyListeners();
  }

  void setSort(String field, String direction) {
    _sortField = field;
    _sortDirection = direction;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void clearClientesDisponibles() {
    _clientesDisponibles = [];
    notifyListeners();
  }

  void clearProductosDisponibles() {
    _productosDisponibles = [];
    notifyListeners();
  }
}
