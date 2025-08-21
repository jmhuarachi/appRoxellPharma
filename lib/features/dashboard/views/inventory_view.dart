import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:roxellpharma/core/costants/api_constants.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';
import 'package:roxellpharma/core/utils/storage_util.dart';
import 'package:roxellpharma/core/widgets/loading_button.dart';
import 'package:roxellpharma/features/auth/domain/models/user_model.dart';
import 'package:roxellpharma/features/auth/presentation/providers/auth_provider.dart';

class InventoryItem {
  final int id;
  final int productoId;
  final String nombreProducto;
  final String composicionProducto;
  final int sucursalId;
  final String nombreSucursal;
  final int stock;
  final int stockMinimo;
  final int stockMaximo;
  final double precioContado;
  final double precioCredito;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MovimientoInventario> movimientos;

  InventoryItem({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.composicionProducto,
    required this.sucursalId,
    required this.nombreSucursal,
    required this.stock,
    required this.stockMinimo,
    required this.stockMaximo,
    required this.precioContado,
    required this.precioCredito,
    required this.createdAt,
    required this.updatedAt,
    required this.movimientos,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      productoId: json['producto_id'],
      nombreProducto: json['nombre_producto'],
      composicionProducto: json['composicion_producto'] ?? '',
      sucursalId: json['sucursal_id'],
      nombreSucursal: json['nombre_sucursal'],
      stock: json['stock'],
      stockMinimo: json['stock_minimo'],
      stockMaximo: json['stock_maximo'],
      precioContado: json['precio_contado'].toDouble(),
      precioCredito: json['precio_credito'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      movimientos: (json['movimientos'] as List? ?? [])
          .map((e) => MovimientoInventario.fromJson(e))
          .toList(),
    );
  }
}

class MovimientoInventario {
  final int id;
  final String tipo;
  final int productoId;
  final int? sucursalOrigenId;
  final int? sucursalDestinoId;
  final int cantidad;
  final int adminId;
  final String? notas;
  final DateTime fecha;
  final String tipoFormateado;
  final String descripcion;
  final String? adminNombre;
  final String? sucursalOrigenNombre;
  final String? sucursalDestinoNombre;

  MovimientoInventario({
    required this.id,
    required this.tipo,
    required this.productoId,
    this.sucursalOrigenId,
    this.sucursalDestinoId,
    required this.cantidad,
    required this.adminId,
    this.notas,
    required this.fecha,
    required this.tipoFormateado,
    required this.descripcion,
    this.adminNombre,
    this.sucursalOrigenNombre,
    this.sucursalDestinoNombre,
  });

  factory MovimientoInventario.fromJson(Map<String, dynamic> json) {
    return MovimientoInventario(
      id: json['id'],
      tipo: json['tipo'],
      productoId: json['producto_id'],
      sucursalOrigenId: json['sucursal_origen_id'],
      sucursalDestinoId: json['sucursal_destino_id'],
      cantidad: json['cantidad'],
      adminId: json['admin_id'],
      notas: json['notas'],
      fecha: DateTime.parse(json['fecha']),
      tipoFormateado: json['tipo_formateado'],
      descripcion: json['descripcion'],
      adminNombre: json['admin']?['nombre'],
      sucursalOrigenNombre: json['sucursal_origen']?['nombre'],
      sucursalDestinoNombre: json['sucursal_destino']?['nombre'],
    );
  }
}

class Sucursal {
  final int id;
  final String nombre;

  Sucursal({required this.id, required this.nombre});

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(id: json['id'], nombre: json['nombre']);
  }
}

class ProductoDisponible {
  final int id;
  final String nombre;
  final String composicion;
  final String presentacion;
  final String? categoria;

  ProductoDisponible({
    required this.id,
    required this.nombre,
    required this.composicion,
    required this.presentacion,
    this.categoria,
  });

  factory ProductoDisponible.fromJson(Map<String, dynamic> json) {
    return ProductoDisponible(
      id: json['id'],
      nombre: json['nombre'],
      composicion: json['composicion'],
      presentacion: json['presentacion'],
      categoria: json['categoria'],
    );
  }
}

class InventoryProvider with ChangeNotifier {
  final StorageUtil _storage;
  final http.Client _client;

  List<InventoryItem> _inventoryItems = [];
  List<Sucursal> _sucursales = [];
  List<ProductoDisponible> _productosDisponibles = [];
  List<Sucursal> _sucursalesDisponibles = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedStockStatus = 'todos';
  String _selectedSucursal = 'todas';
  String _sortField = 'producto.nombre';
  String _sortDirection = 'asc';
  int _currentPage = 1;
  int _totalItems = 0;
  int _itemsPerPage = 10;

  String get selectedStockStatus => _selectedStockStatus;
  String get selectedSucursal => _selectedSucursal;
  String get sortField => _sortField;
  String get sortDirection => _sortDirection;
  String get searchQuery => _searchQuery;

  InventoryProvider(this._storage, [http.Client? client])
    : _client = client ?? http.Client();

  List<InventoryItem> get inventoryItems => _inventoryItems;
  List<Sucursal> get sucursales => _sucursales;
  List<ProductoDisponible> get productosDisponibles => _productosDisponibles;
  List<Sucursal> get sucursalesDisponibles => _sucursalesDisponibles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalItems => _totalItems;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  Future<void> loadInventory() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      final user = await _storage.getUser();

      if (token == null || user == null) {
        throw Exception('No autenticado - Por favor inicie sesión nuevamente');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/v1/inventario?'
        'page=$_currentPage'
        '&per_page=$_itemsPerPage'
        '&search=$_searchQuery'
        '&estado_stock=$_selectedStockStatus'
        '&sucursal_id=${_selectedSucursal == 'todas' ? '' : _selectedSucursal}'
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

        _inventoryItems = (responseData['data'] as List)
            .map((item) => InventoryItem.fromJson(item))
            .toList();

        _totalItems = responseData['total'];
        _currentPage = responseData['current_page'];
        _itemsPerPage = responseData['per_page'];

        _sucursales = (responseData['sucursales'] as List)
            .map((item) => Sucursal.fromJson(item))
            .toList();

        _error = null;
      } else if (response.statusCode == 401) {
        // Token inválido o expirado
        throw Exception('Sesión expirada - Por favor inicie sesión nuevamente');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Error al cargar el inventario',
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

  Future<void> loadProductosDisponibles(
    String search, {
    int? sucursalId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/v1/inventario/productos-disponibles?'
        'search=$search'
        '${sucursalId != null ? '&sucursal_id=$sucursalId' : ''}',
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
        if (responseData['success'] == true) {
          _productosDisponibles = (responseData['data']['productos'] as List)
              .map((item) => ProductoDisponible.fromJson(item))
              .toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'Error al cargar productos disponibles',
          );
        }
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

  Future<void> loadSucursalesDisponibles(int productoId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/v1/inventario/sucursales-disponibles/$productoId',
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

        // Verificar si la respuesta tiene estructura {success: true, data: [...]}
        if (responseData is Map && responseData.containsKey('data')) {
          _sucursalesDisponibles = (responseData['data'] as List)
              .map((item) => Sucursal.fromJson(item))
              .toList();
        }
        // O si es directamente una lista (por compatibilidad)
        else if (responseData is List) {
          _sucursalesDisponibles = (responseData as List)
              .map((item) => Sucursal.fromJson(item))
              .toList();
        } else {
          throw Exception('Formato de respuesta no válido');
        }
      } else {
        throw Exception(
          'Error al cargar sucursales disponibles: ${response.statusCode}',
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

  Future<void> createInventoryItem(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse('${ApiConstants.baseUrl}/v1/inventario');

      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        await loadInventory();
        _error = null;
      } else {
        throw Exception(
          responseData['message'] ??
              'Error al crear inventario: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      rethrow; // Esto permite que el diálogo muestre el error específico
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInventoryItem(int id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse('${ApiConstants.baseUrl}/v1/inventario/$id');

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
        throw Exception(
          'Error al actualizar inventario: ${response.statusCode}',
        );
      }

      await loadInventory();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> transferInventory(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse('${ApiConstants.baseUrl}/v1/inventario/transferir');

      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al transferir inventario: ${response.statusCode}',
        );
      }

      await loadInventory();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInventoryItem(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse('${ApiConstants.baseUrl}/v1/inventario/$id');

      final response = await _client.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar inventario: ${response.statusCode}');
      }

      await loadInventory();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMovimientos(int productoId) async {
    try {
      final token = await _storage.getToken();
      if (token == null) throw Exception('No autenticado');

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/v1/inventario/movimientos/$productoId',
      );

      final response = await _client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final index = _inventoryItems.indexWhere(
          (item) => item.productoId == productoId,
        );
        if (index != -1) {
          _inventoryItems[index] = _inventoryItems[index].copyWith(
            movimientos: (data['movimientos'] as List)
                .map((e) => MovimientoInventario.fromJson(e))
                .toList(),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error al cargar movimientos: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();
  }

  void setStockStatus(String status) {
    _selectedStockStatus = status;
    _currentPage = 1;
    notifyListeners();
  }

  void setSucursal(String sucursal) {
    _selectedSucursal = sucursal;
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

  void clearProductosDisponibles() {
    _productosDisponibles = [];
    notifyListeners();
  }

  void clearSucursalesDisponibles() {
    _sucursalesDisponibles = [];
    notifyListeners();
  }
}

extension InventoryItemExtension on InventoryItem {
  InventoryItem copyWith({List<MovimientoInventario>? movimientos}) {
    return InventoryItem(
      id: id,
      productoId: productoId,
      nombreProducto: nombreProducto,
      composicionProducto: composicionProducto,
      sucursalId: sucursalId,
      nombreSucursal: nombreSucursal,
      stock: stock,
      stockMinimo: stockMinimo,
      stockMaximo: stockMaximo,
      precioContado: precioContado,
      precioCredito: precioCredito,
      createdAt: createdAt,
      updatedAt: updatedAt,
      movimientos: movimientos ?? this.movimientos,
    );
  }
}

class InventoryView extends StatefulWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  _InventoryViewState createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showAdvancedFilters = false;
  final Map<String, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      provider.loadInventory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      if (provider.currentPage * provider.itemsPerPage < provider.totalItems) {
        provider.setPage(provider.currentPage + 1);
        provider.loadInventory();
      }
    }
  }

  String _getStockStatus(InventoryItem item) {
    if (item.stock <= item.stockMinimo) return 'critico';
    if (item.stock <= item.stockMinimo * 1.5) return 'bajo';
    if (item.stock >= item.stockMaximo * 0.8) return 'alto';
    return 'normal';
  }

  Color _getStockStatusColor(String status) {
    switch (status) {
      case 'critico':
        return AppColors.red600;
      case 'bajo':
        return AppColors.yellow600;
      case 'alto':
        return AppColors.blue600;
      case 'normal':
      default:
        return AppColors.green600;
    }
  }

  IconData _getStockStatusIcon(String status) {
    switch (status) {
      case 'critico':
        return Icons.warning;
      case 'bajo':
        return Icons.trending_down;
      case 'alto':
        return Icons.trending_up;
      case 'normal':
      default:
        return Icons.check_circle;
    }
  }

  String _getStockStatusText(String status) {
    switch (status) {
      case 'critico':
        return 'Crítico';
      case 'bajo':
        return 'Bajo';
      case 'alto':
        return 'Alto';
      case 'normal':
      default:
        return 'Normal';
    }
  }

  void _showAddInventoryDialog() {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user!;

    final _formKey = GlobalKey<FormState>();
    final _productSearchController = TextEditingController();
    final _stockController = TextEditingController(text: '0');
    final _minStockController = TextEditingController(text: '0');
    final _maxStockController = TextEditingController(text: '0');
    final _cashPriceController = TextEditingController(text: '0.00');
    final _creditPriceController = TextEditingController(text: '0.00');

    ProductoDisponible? _selectedProduct;
    Sucursal? _selectedSucursal;
    bool _isLoadingProducts = false;
    bool _isLoadingSucursales = false;
    int _currentStep = 1;
    String? _errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 700,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currentStep == 1
                                ? 'Seleccionar Producto'
                                : 'Datos de Inventario',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                              provider.clearProductosDisponibles();
                              provider.clearSucursalesDisponibles();
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_currentStep == 1) ...[
                                  // Paso 1: Selección de producto
                                  TextFormField(
                                    controller: _productSearchController,
                                    decoration: InputDecoration(
                                      labelText: 'Buscar Producto',
                                      prefixIcon: const Icon(Icons.search),
                                      border: const OutlineInputBorder(),
                                      suffixIcon: _selectedProduct != null
                                          ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedProduct = null;
                                                  _productSearchController
                                                      .clear();
                                                  provider
                                                      .clearProductosDisponibles();
                                                });
                                              },
                                            )
                                          : null,
                                    ),
                                    onChanged: (value) async {
                                      if (value.length > 2) {
                                        setState(
                                          () => _isLoadingProducts = true,
                                        );
                                        try {
                                          await provider
                                              .loadProductosDisponibles(
                                                value,
                                                sucursalId: user.isSuperAdmin
                                                    ? null
                                                    : user.sucursalId,
                                              );
                                        } catch (e) {
                                          setState(() {
                                            _errorMessage =
                                                'Error al buscar productos: ${e.toString()}';
                                          });
                                        } finally {
                                          setState(
                                            () => _isLoadingProducts = false,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  if (_isLoadingProducts)
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  else if (_errorMessage != null)
                                    Text(
                                      _errorMessage!,
                                      style: TextStyle(color: AppColors.red600),
                                    )
                                  else if (provider
                                          .productosDisponibles
                                          .isEmpty &&
                                      _productSearchController.text.isNotEmpty)
                                    const Text('No se encontraron productos')
                                  else
                                    SizedBox(
                                      height: 200,
                                      child: ListView.separated(
                                        itemCount: provider
                                            .productosDisponibles
                                            .length,
                                        itemBuilder: (context, index) {
                                          final producto = provider
                                              .productosDisponibles[index];
                                          return ListTile(
                                            title: Text(producto.nombre),
                                            subtitle: Text(
                                              '${producto.composicion} - ${producto.presentacion}',
                                            ),
                                            trailing: Text(
                                              producto.categoria ?? '',
                                            ),
                                            onTap: () async {
                                              setState(() {
                                                _selectedProduct = producto;
                                                _productSearchController.text =
                                                    producto.nombre;
                                                _isLoadingSucursales = true;
                                                _errorMessage = null;
                                              });

                                              try {
                                                await provider
                                                    .loadSucursalesDisponibles(
                                                      producto.id,
                                                    );
                                                if (provider
                                                    .sucursalesDisponibles
                                                    .isNotEmpty) {
                                                  setState(() {
                                                    _selectedSucursal = provider
                                                        .sucursalesDisponibles
                                                        .first;
                                                  });
                                                } else {
                                                  setState(() {
                                                    _errorMessage =
                                                        'No hay sucursales disponibles para este producto';
                                                  });
                                                }
                                              } catch (e) {
                                                setState(() {
                                                  _errorMessage =
                                                      'Error al cargar sucursales: ${e.toString()}';
                                                });
                                              } finally {
                                                setState(
                                                  () => _isLoadingSucursales =
                                                      false,
                                                );
                                              }
                                            },
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const Divider(height: 1),
                                      ),
                                    ),

                                  if (_selectedProduct != null) ...[
                                    const SizedBox(height: 16),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedProduct!.nombre,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (_selectedProduct!
                                                .composicion
                                                .isNotEmpty)
                                              Text(
                                                _selectedProduct!.composicion,
                                              ),
                                            if (_selectedProduct!
                                                .presentacion
                                                .isNotEmpty)
                                              Text(
                                                _selectedProduct!.presentacion,
                                              ),
                                            if (_selectedProduct!.categoria !=
                                                null)
                                              Text(
                                                'Categoría: ${_selectedProduct!.categoria}',
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ] else ...[
                                  // Paso 2: Datos de inventario
                                  if (_selectedProduct == null ||
                                      _selectedSucursal == null)
                                    const Text(
                                      'Error: No se seleccionó producto o sucursal',
                                      style: TextStyle(color: AppColors.red600),
                                    )
                                  else ...[
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedProduct!.nombre,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(_selectedProduct!.composicion),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Sucursal: ${_selectedSucursal!.nombre}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Selector de sucursal (solo para super admin)
                                    if (user.isSuperAdmin)
                                      DropdownButtonFormField<Sucursal>(
                                        value: _selectedSucursal,
                                        decoration: const InputDecoration(
                                          labelText: 'Sucursal',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: provider.sucursalesDisponibles
                                            .map((sucursal) {
                                              return DropdownMenuItem<Sucursal>(
                                                value: sucursal,
                                                child: Text(sucursal.nombre),
                                              );
                                            })
                                            .toList(),
                                        onChanged: (sucursal) {
                                          setState(() {
                                            _selectedSucursal = sucursal;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Seleccione una sucursal';
                                          }
                                          return null;
                                        },
                                      ),

                                    const SizedBox(height: 16),

                                    // Stock inicial
                                    TextFormField(
                                      controller: _stockController,
                                      decoration: const InputDecoration(
                                        labelText: 'Stock Inicial',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese el stock';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Número inválido';
                                        }
                                        if (int.parse(value) < 0) {
                                          return 'El stock no puede ser negativo';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Stock mínimo
                                    TextFormField(
                                      controller: _minStockController,
                                      decoration: const InputDecoration(
                                        labelText: 'Stock Mínimo',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese el stock mínimo';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Número inválido';
                                        }
                                        if (int.parse(value) < 0) {
                                          return 'El stock mínimo no puede ser negativo';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Stock máximo
                                    TextFormField(
                                      controller: _maxStockController,
                                      decoration: const InputDecoration(
                                        labelText: 'Stock Máximo',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese el stock máximo';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Número inválido';
                                        }
                                        if (int.parse(value) < 0) {
                                          return 'El stock máximo no puede ser negativo';
                                        }
                                        if (_minStockController
                                                .text
                                                .isNotEmpty &&
                                            int.parse(value) <
                                                int.parse(
                                                  _minStockController.text,
                                                )) {
                                          return 'Debe ser mayor al stock mínimo';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Precio contado
                                    TextFormField(
                                      controller: _cashPriceController,
                                      decoration: const InputDecoration(
                                        labelText: 'Precio Contado (Bs.)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese el precio';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Número inválido';
                                        }
                                        if (double.parse(value) < 0) {
                                          return 'El precio no puede ser negativo';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Precio crédito
                                    TextFormField(
                                      controller: _creditPriceController,
                                      decoration: const InputDecoration(
                                        labelText: 'Precio Crédito (Bs.)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese el precio';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Número inválido';
                                        }
                                        if (double.parse(value) < 0) {
                                          return 'El precio no puede ser negativo';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_currentStep == 2)
                            TextButton(
                              onPressed: () {
                                setState(() => _currentStep = 1);
                              },
                              child: const Text('Atrás'),
                            ),
                          if (_currentStep == 1)
                            ElevatedButton(
                              onPressed: () {
                                if (_selectedProduct == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Seleccione un producto'),
                                    ),
                                  );
                                  return;
                                }

                                if (provider.sucursalesDisponibles.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No hay sucursales disponibles para este producto',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _currentStep = 2);
                              },
                              child: const Text('Siguiente'),
                            )
                          else
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate() &&
                                    _selectedProduct != null &&
                                    _selectedSucursal != null) {
                                  final data = {
                                    'producto_id': _selectedProduct!.id,
                                    'sucursal_id': _selectedSucursal!.id,
                                    'stock': int.parse(_stockController.text),
                                    'stock_minimo': int.parse(
                                      _minStockController.text,
                                    ),
                                    'stock_maximo': int.parse(
                                      _maxStockController.text,
                                    ),
                                    'precio_contado': double.parse(
                                      _cashPriceController.text,
                                    ),
                                    'precio_credito': double.parse(
                                      _creditPriceController.text,
                                    ),
                                  };

                                  try {
                                    await provider.createInventoryItem(data);
                                    if (mounted) {
                                      Navigator.pop(context);
                                      provider.clearProductosDisponibles();
                                      provider.clearSucursalesDisponibles();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Inventario creado exitosamente',
                                          ),
                                          backgroundColor: AppColors.green600,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error al crear inventario: ${e.toString()}',
                                          ),
                                          backgroundColor: AppColors.red600,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              child: const Text('Guardar Inventario'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      provider.clearProductosDisponibles();
      provider.clearSucursalesDisponibles();
    });
  }

  void _showEditInventoryDialog(InventoryItem item) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    final _formKey = GlobalKey<FormState>();
    final _stockController = TextEditingController(text: item.stock.toString());
    final _minStockController = TextEditingController(
      text: item.stockMinimo.toString(),
    );
    final _maxStockController = TextEditingController(
      text: item.stockMaximo.toString(),
    );
    final _cashPriceController = TextEditingController(
      text: item.precioContado.toStringAsFixed(2),
    );
    final _creditPriceController = TextEditingController(
      text: item.precioCredito.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar ${item.nombreProducto}'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stock Actual
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: 'Stock Actual',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el stock actual';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Stock Mínimo
                  TextFormField(
                    controller: _minStockController,
                    decoration: InputDecoration(
                      labelText: 'Stock Mínimo',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el stock mínimo';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Stock Máximo
                  TextFormField(
                    controller: _maxStockController,
                    decoration: InputDecoration(
                      labelText: 'Stock Máximo',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el stock máximo';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      if (int.parse(value) <
                          int.parse(_minStockController.text)) {
                        return 'Debe ser mayor que el stock mínimo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Precio Contado
                  TextFormField(
                    controller: _cashPriceController,
                    decoration: InputDecoration(
                      labelText: 'Precio Contado (Bs.)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el precio contado';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Precio Crédito
                  TextFormField(
                    controller: _creditPriceController,
                    decoration: InputDecoration(
                      labelText: 'Precio Crédito (Bs.)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el precio crédito';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final data = {
                    'stock': int.parse(_stockController.text),
                    'stock_minimo': int.parse(_minStockController.text),
                    'stock_maximo': int.parse(_maxStockController.text),
                    'precio_contado': double.parse(_cashPriceController.text),
                    'precio_credito': double.parse(_creditPriceController.text),
                  };

                  provider
                      .updateInventoryItem(item.id, data)
                      .then((_) {
                        Navigator.pop(context);
                      })
                      .catchError((e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      });
                }
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferDialog(InventoryItem item) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final user = Provider.of<User>(context, listen: false);

    final _formKey = GlobalKey<FormState>();
    final _quantityController = TextEditingController();
    final _notesController = TextEditingController();
    String? _selectedDestinationSucursalId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Transferir ${item.nombreProducto}'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cantidad a Transferir
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Cantidad a Transferir',
                          hintText: 'Máximo: ${item.stock}',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la cantidad';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingrese un número válido';
                          }
                          if (int.parse(value) <= 0) {
                            return 'La cantidad debe ser mayor a 0';
                          }
                          if (int.parse(value) > item.stock) {
                            return 'No hay suficiente stock';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Sucursal Destino
                      DropdownButtonFormField<String>(
                        value: _selectedDestinationSucursalId,
                        decoration: InputDecoration(
                          labelText: 'Sucursal Destino',
                          border: OutlineInputBorder(),
                        ),
                        items: provider.sucursales
                            .where((sucursal) => sucursal.id != item.sucursalId)
                            .map((sucursal) {
                              return DropdownMenuItem(
                                value: sucursal.id.toString(),
                                child: Text(sucursal.nombre),
                              );
                            })
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDestinationSucursalId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione una sucursal destino';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Notas
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notas (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedDestinationSucursalId != null) {
                      final data = {
                        'producto_id': item.productoId,
                        'sucursal_origen_id': item.sucursalId,
                        'sucursal_destino_id': int.parse(
                          _selectedDestinationSucursalId!,
                        ),
                        'cantidad': int.parse(_quantityController.text),
                        'notas': _notesController.text.isNotEmpty
                            ? _notesController.text
                            : null,
                      };

                      provider
                          .transferInventory(data)
                          .then((_) {
                            Navigator.pop(context);
                          })
                          .catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          });
                    }
                  },
                  child: const Text('Confirmar Transferencia'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(InventoryItem item) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Está seguro de eliminar este producto del inventario?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Producto: ${item.nombreProducto}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Sucursal: ${item.nombreSucursal}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (item.stock > 0)
                Text(
                  '⚠️ Advertencia: Este producto tiene ${item.stock} unidades en stock.',
                  style: TextStyle(color: AppColors.red600),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                provider
                    .deleteInventoryItem(item.id)
                    .then((_) {
                      Navigator.pop(context);
                    })
                    .catchError((e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red600,
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleExpanded(String key, int productoId) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    setState(() {
      if (!_expandedItems.containsKey(key) || !_expandedItems[key]!) {
        provider.loadMovimientos(productoId);
      }
      _expandedItems[key] = !(_expandedItems[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final user = Provider.of<AuthProvider>(context, listen: false).user!;

    // Estadísticas
    final criticalCount = provider.inventoryItems
        .where((item) => _getStockStatus(item) == 'critico')
        .length;
    final lowCount = provider.inventoryItems
        .where((item) => _getStockStatus(item) == 'bajo')
        .length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadInventory();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Estadísticas
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatCard(
                            'Total Productos',
                            provider.totalItems.toString(),
                            Icons.inventory_2_rounded,
                            AppColors.blue500,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Stock Crítico',
                            criticalCount.toString(),
                            Icons.warning_rounded,
                            AppColors.red600,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Stock Bajo',
                            lowCount.toString(),
                            Icons.trending_down_rounded,
                            AppColors.yellow600,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Sucursales',
                            provider.sucursales.length.toString(),
                            Icons.store_rounded,
                            AppColors.green600,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Buscador y Filtros
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar productos...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        provider.setSearchQuery('');
                                        provider.loadInventory();
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              provider.setSearchQuery(value);
                              provider.loadInventory();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showAdvancedFilters = !_showAdvancedFilters;
                            });
                          },
                          icon: const Icon(Icons.filter_alt_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: _showAdvancedFilters
                                ? AppColors.orange600
                                : AppColors.gray200,
                            foregroundColor: _showAdvancedFilters
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),

                    // Filtros avanzados
                    if (_showAdvancedFilters)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Estado de Stock
                                DropdownButtonFormField<String>(
                                  value: 'todos',
                                  decoration: InputDecoration(
                                    labelText: 'Estado de Stock',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      [
                                        {'value': 'todos', 'label': 'Todos'},
                                        {
                                          'value': 'critico',
                                          'label': 'Crítico',
                                        },
                                        {'value': 'bajo', 'label': 'Bajo'},
                                        {'value': 'normal', 'label': 'Normal'},
                                        {'value': 'alto', 'label': 'Alto'},
                                      ].map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item['value'],
                                          child: Text(item['label']!),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    provider.setStockStatus(value!);
                                    provider.loadInventory();
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Sucursal (solo para super admin)
                                if (user.isSuperAdmin)
                                  DropdownButtonFormField<String>(
                                    value: 'todas',
                                    decoration: InputDecoration(
                                      labelText: 'Sucursal',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: 'todas',
                                        child: Text('Todas las sucursales'),
                                      ),
                                      ...provider.sucursales.map((sucursal) {
                                        return DropdownMenuItem<String>(
                                          value: sucursal.id.toString(),
                                          child: Text(sucursal.nombre),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      provider.setSucursal(value!);
                                      provider.loadInventory();
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Lista de inventario
            if (provider.isLoading && provider.inventoryItems.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.inventoryItems.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No se encontraron productos',
                    style: TextStyle(color: AppColors.gray500),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = provider.inventoryItems[index];
                  final stockStatus = _getStockStatus(item);
                  final key = '${item.productoId}-${item.sucursalId}';

                  return Card(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: ExpansionTile(
                      initiallyExpanded: _expandedItems[key] ?? false,
                      onExpansionChanged: (expanded) {
                        _toggleExpanded(key, item.productoId);
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStockStatusColor(
                            stockStatus,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getStockStatusIcon(stockStatus),
                          color: _getStockStatusColor(stockStatus),
                        ),
                      ),
                      title: Text(
                        item.nombreProducto,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.composicionProducto),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14),
                              const SizedBox(width: 4),
                              Text(item.nombreSucursal),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.stock.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Stock', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Detalles del producto
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return GridView(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 2,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                    children: [
                                      _buildDetailTile(
                                        'Stock Mínimo',
                                        item.stockMinimo.toString(),
                                      ),
                                      _buildDetailTile(
                                        'Stock Máximo',
                                        item.stockMaximo.toString(),
                                      ),
                                      _buildDetailTile(
                                        'Precio Contado',
                                        'Bs. ${item.precioContado.toStringAsFixed(2)}',
                                      ),
                                      _buildDetailTile(
                                        'Precio Crédito',
                                        'Bs. ${item.precioCredito.toStringAsFixed(2)}',
                                      ),
                                      _buildDetailTile(
                                        '% Disponible',
                                        '${((item.stock / item.stockMaximo) * 100).toStringAsFixed(0)}%',
                                        showProgress: true,
                                        progressValue:
                                            item.stock / item.stockMaximo,
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Botones de acción
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (user.isAdmin || user.isSuperAdmin)
                                    IconButton(
                                      onPressed: () =>
                                          _showEditInventoryDialog(item),
                                      icon: const Icon(Icons.edit),
                                      color: AppColors.blue600,
                                      tooltip: 'Editar',
                                    ),
                                  if (user.isAdmin || user.isSuperAdmin)
                                    IconButton(
                                      onPressed: () =>
                                          _showTransferDialog(item),
                                      icon: const Icon(Icons.swap_horiz),
                                      color: AppColors.purple600,
                                      tooltip: 'Transferir',
                                    ),
                                  if (user.isSuperAdmin)
                                    IconButton(
                                      onPressed: () =>
                                          _showDeleteConfirmation(item),
                                      icon: const Icon(Icons.delete),
                                      color: AppColors.red600,
                                      tooltip: 'Eliminar',
                                    ),
                                ],
                              ),

                              // Historial de movimientos
                              const Divider(),
                              const Text(
                                'Historial de Movimientos',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),

                              if (item.movimientos.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(
                                    'No hay movimientos registrados para este producto',
                                    style: TextStyle(color: AppColors.gray500),
                                  ),
                                )
                              else
                                ...item.movimientos.map((movimiento) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(movimiento.descripcion),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${movimiento.fecha.toLocal().toString().substring(0, 16)} - ${movimiento.adminNombre ?? 'Sistema'}',
                                        ),
                                        if (movimiento.notas != null)
                                          Text('Notas: ${movimiento.notas}'),
                                      ],
                                    ),
                                    trailing: Text(
                                      '${movimiento.cantidad} unidades',
                                      style: TextStyle(
                                        color: movimiento.tipo == 'entrada'
                                            ? AppColors.green600
                                            : AppColors.red600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: provider.inventoryItems.length),
              ),

            // Paginación
            if (provider.isLoading && provider.inventoryItems.isNotEmpty)
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.totalItems > provider.itemsPerPage)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: provider.currentPage > 1
                            ? () {
                                provider.setPage(provider.currentPage - 1);
                                provider.loadInventory();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        'Página ${provider.currentPage} de ${(provider.totalItems / provider.itemsPerPage).ceil()}',
                      ),
                      IconButton(
                        onPressed:
                            provider.currentPage * provider.itemsPerPage <
                                provider.totalItems
                            ? () {
                                provider.setPage(provider.currentPage + 1);
                                provider.loadInventory();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: (user.isAdmin || user.isSuperAdmin)
          ? FloatingActionButton(
              onPressed: _showAddInventoryDialog,
              backgroundColor: AppColors.orange600,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppColors.gray600, fontSize: 14),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    String title,
    String value, {
    bool showProgress = false,
    double? progressValue,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.gray600, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (showProgress && progressValue != null)
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: AppColors.gray200,
              color: progressValue < 0.2
                  ? AppColors.red600
                  : progressValue < 0.5
                  ? AppColors.yellow600
                  : AppColors.green600,
            ),
        ],
      ),
    );
  }
}
