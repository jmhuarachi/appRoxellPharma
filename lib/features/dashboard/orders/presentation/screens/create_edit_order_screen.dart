// lib/features/dashboard/views/create_edit_order_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';
import 'package:roxellpharma/core/costants/api_constants.dart';
import 'package:roxellpharma/core/utils/storage_util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateEditOrderScreen extends StatefulWidget {
  final Map<String, dynamic>? order;

  const CreateEditOrderScreen({super.key, this.order});

  @override
  State<CreateEditOrderScreen> createState() => _CreateEditOrderScreenState();
}

class _CreateEditOrderScreenState extends State<CreateEditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  // Cliente y sucursal
  int? _selectedClientId;
  String? _selectedClientName;
  String? _selectedClientNit;
  int? _selectedBranchId;
  final TextEditingController _deliveryAddressController = TextEditingController();

  // Información del pedido
  String _paymentMethod = 'Contado';
  int _creditTerm = 30;
  DateTime? _deliveryDate;
  TimeOfDay? _deliveryTime;
  final TextEditingController _notesController = TextEditingController();

  // Productos
  final List<Map<String, dynamic>> _selectedProducts = [];
  final TextEditingController _productSearchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProducts = [];
  Map<String, dynamic>? _selectedProduct;
  int _productQuantity = 1;
  double _productUnitPrice = 0.0;
  String _discountType = 'ninguno';
  double _discountValue = 0.0;
  bool _showProductForm = false;
  bool _isLoading = false;

  // Listas de opciones
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _loadOrderData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final storage = Provider.of<StorageUtil>(context, listen: false);
      await Future.wait([
        _loadClients(storage),
        _loadBranches(storage),
        _loadProducts(storage),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClients(StorageUtil storage) async {
    final token = await storage.getToken();
    
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/v1/pedidos/clientes-disponibles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _clients = (data['data'] as List).map((client) {
          return {
            'id': client['id'],
            'name': client['nombre'],
            'nit': client['nit'],
          };
        }).toList();
      });
    } else {
      throw Exception('Error al cargar clientes');
    }
  }

  Future<void> _loadBranches(StorageUtil storage) async {
    final token = await storage.getToken();
    final user = await storage.getUser();

    // Para admin normal, solo puede ver su sucursal
    if (user != null && !user.isSuperAdmin) {
      setState(() {
        _branches = [
          {
            'id': user.sucursalId,
            'name': user.sucursalName,
          }
        ];
        _selectedBranchId = user.sucursalId;
      });
      _loadProducts(storage);
      return;
    }

    // Para super admin, cargar todas las sucursales
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/v1/inventario/form-data'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _branches = (data['data']['sucursales'] as List).map((sucursal) {
          return {
            'id': sucursal['id'],
            'name': sucursal['nombre'],
          };
        }).toList();
      });
    }
  }

  Future<void> _loadProducts(StorageUtil storage) async {
    if (_selectedBranchId == null) return;

    final token = await storage.getToken();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/v1/pedidos/productos-disponibles?sucursal_id=$_selectedBranchId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _products = (data['data'] as List).map((product) {
          return {
            'id': product['id'],
            'product_id': product['id'],
            'name': product['nombre'],
            'presentation': product['presentacion'],
            'stock': product['stock'],
            'cash_price': product['precio_contado'],
            'credit_price': product['precio_credito'],
          };
        }).toList();
        _filterProducts();
      });
    }
  }

  void _loadOrderData() {
    final order = widget.order!;
    setState(() {
      _selectedClientId = order['cliente_id'];
      _selectedClientName = order['cliente_nombre'];
      _selectedClientNit = order['cliente_nit'];
      _selectedBranchId = order['sucursal_id'];
      _deliveryAddressController.text = order['direccion_entrega'];
      _paymentMethod = order['metodo_pago'];
      _creditTerm = order['plazo_credito'] ?? 30;
      _deliveryDate = DateTime.parse(order['fecha_entrega']);
      _deliveryTime = _parseTime(order['hora_entrega_estimada'] ?? '12:00');
      _notesController.text = order['notas_cliente'] ?? '';

      _selectedProducts.clear();
      _selectedProducts.addAll(
        (order['productos'] as List).map<Map<String, dynamic>>((p) {
          return {
            'id': p['id'],
            'product_id': p['producto_id'],
            'name': p['nombre'],
            'presentation': p['presentacion'],
            'quantity': p['cantidad'],
            'unit_price': p['precio_unitario'],
            'discount_type': p['tipo_descuento'] ?? 'ninguno',
            'discount_value': p['valor_descuento'] ?? 0.0,
            'subtotal': p['subtotal'],
          };
        }).toList(),
      );
    });
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order != null ? 'Editar Pedido' : 'Nuevo Pedido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del cliente
                    _buildClientInfoSection(),
                    const SizedBox(height: 20),

                    // Información del pedido
                    _buildOrderInfoSection(),
                    const SizedBox(height: 20),

                    // Productos
                    _buildProductsSection(),
                    const SizedBox(height: 20),

                    // Resumen y totales
                    _buildOrderSummary(),
                    const SizedBox(height: 20),

                    // Botones de acción
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildClientInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: AppColors.blue600),
                const SizedBox(width: 8),
                Text(
                  'Información del Cliente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selección de cliente
            DropdownButtonFormField<int>(
              value: _selectedClientId,
              decoration: InputDecoration(
                labelText: 'Cliente *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              isExpanded: true,
              items: _clients.map((client) {
                return DropdownMenuItem<int>(
                  value: client['id'],
                  child: Text(
                    '${client['name']} (NIT: ${client['nit']})',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClientId = value;
                  final client = _clients.firstWhere(
                    (c) => c['id'] == value,
                    orElse: () => {'name': '', 'nit': ''},
                  );
                  _selectedClientName = client['name'];
                  _selectedClientNit = client['nit'];
                });
              },
              validator: (value) {
                if (value == null) return 'Seleccione un cliente';
                return null;
              },
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 16),

            // Dirección de entrega
            TextFormField(
              controller: _deliveryAddressController,
              decoration: InputDecoration(
                labelText: 'Dirección de Entrega *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese la dirección de entrega';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_cart,
                  size: 20,
                  color: AppColors.blue600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información del Pedido',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selección de sucursal
            DropdownButtonFormField<int>(
              value: _selectedBranchId,
              decoration: InputDecoration(
                labelText: 'Sucursal *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _branches.map((branch) {
                return DropdownMenuItem<int>(
                  value: branch['id'],
                  child: Text(branch['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBranchId = value;
                  final storage = Provider.of<StorageUtil>(context, listen: false);
                  _loadProducts(storage);
                });
              },
              validator: (value) {
                if (value == null) return 'Seleccione una sucursal';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fecha y hora de entrega
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDeliveryDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha de Entrega *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _deliveryDate != null
                                ? DateFormat('dd/MM/yyyy').format(_deliveryDate!)
                                : 'dd/mm/yyyy',
                          ),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDeliveryTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Hora de Entrega *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _deliveryTime != null
                                ? _deliveryTime!.format(context)
                                : 'Seleccionar hora',
                          ),
                          const Icon(Icons.access_time, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Método de pago
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: InputDecoration(
                labelText: 'Método de Pago *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Contado', child: Text('Contado')),
                DropdownMenuItem(value: 'Crédito', child: Text('Crédito')),
                DropdownMenuItem(value: 'Mixto', child: Text('Mixto')),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                  _updateProductPrices();
                });
              },
            ),
            const SizedBox(height: 16),

            // Plazo de crédito (solo si el método es Crédito)
            if (_paymentMethod == 'Crédito')
              Column(
                children: [
                  TextFormField(
                    initialValue: _creditTerm.toString(),
                    decoration: InputDecoration(
                      labelText: 'Plazo de Crédito (días) *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _creditTerm = int.tryParse(value) ?? 30;
                    },
                    validator: (value) {
                      if (_paymentMethod == 'Crédito' &&
                          (value == null || value.isEmpty)) {
                        return 'Ingrese el plazo de crédito';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Notas del cliente
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, size: 20, color: AppColors.blue600),
                const SizedBox(width: 8),
                Text(
                  'Productos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Buscador de productos
            TextField(
              controller: _productSearchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre de producto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => _filterProducts(),
            ),
            const SizedBox(height: 16),

            // Lista de productos disponibles (solo si hay búsqueda)
            if (_productSearchController.text.isNotEmpty && !_showProductForm)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Productos Disponibles',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.gray600),
                  ),
                  const SizedBox(height: 8),

                  if (_filteredProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'No se encontraron productos que coincidan con la búsqueda',
                        style: TextStyle(color: AppColors.gray500),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return InkWell(
                          onTap: () => _selectProduct(product),
                          child: Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    product['presentation'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Stock: ${product['stock']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Bs. ${(_paymentMethod == 'Crédito' ? product['credit_price'] : product['cash_price']).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),

            // Formulario para agregar/editar producto
            if (_showProductForm && _selectedProduct != null)
              _buildProductForm(),

            // Lista de productos seleccionados
            if (_selectedProducts.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Productos Seleccionados (${_selectedProducts.length})',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.gray600),
                  ),
                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 12,
                      columns: const [
                        DataColumn(label: Text('Producto')),
                        DataColumn(label: Text('Cant'), numeric: true),
                        DataColumn(label: Text('Precio'), numeric: true),
                        DataColumn(label: Text('Subtotal'), numeric: true),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: _selectedProducts.map((product) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    product['presentation'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                product['quantity'].toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                'Bs. ${product['unit_price'].toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                'Bs. ${product['subtotal'].toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    color: AppColors.blue600,
                                    onPressed: () => _editProduct(product),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: AppColors.red600,
                                    onPressed: () => _removeProduct(product['id']),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No hay productos agregados al pedido',
                  style: TextStyle(color: AppColors.gray500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductForm() {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedProduct!['name']} (${_selectedProduct!['presentation']})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showProductForm = false;
                      _selectedProduct = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cantidad
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cantidad (Stock: ${_selectedProduct!['stock']})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (_productQuantity > 1) {
                      setState(() {
                        _productQuantity--;
                      });
                    }
                  },
                ),
                Container(
                  width: 50,
                  child: TextFormField(
                    initialValue: _productQuantity.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.gray300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requerido';
                      if (int.tryParse(value) == null) return 'Número inválido';
                      if (int.parse(value) > _selectedProduct!['stock']) {
                        return 'Stock insuficiente';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final quantity = int.tryParse(value);
                      if (quantity != null && quantity <= _selectedProduct!['stock']) {
                        setState(() {
                          _productQuantity = quantity;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_productQuantity < _selectedProduct!['stock']) {
                      setState(() {
                        _productQuantity++;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Precio unitario
            TextFormField(
              initialValue: _productUnitPrice.toStringAsFixed(2),
              decoration: InputDecoration(
                labelText: 'Precio Unitario *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _productUnitPrice = double.tryParse(value) ?? 0.0;
              },
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    double.tryParse(value) == null) {
                  return 'Ingrese un precio válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descuento
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _discountType,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Descuento',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ninguno',
                        child: Text('Ninguno'),
                      ),
                      DropdownMenuItem(
                        value: 'porcentaje',
                        child: Text('Porcentaje'),
                      ),
                      DropdownMenuItem(
                        value: 'monto_fijo',
                        child: Text('Monto Fijo'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _discountType = value!;
                        _discountValue = 0.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    enabled: _discountType != 'ninguno',
                    initialValue: _discountValue.toStringAsFixed(2),
                    decoration: InputDecoration(
                      labelText: _discountType == 'porcentaje'
                          ? '% Descuento'
                          : 'Monto Descuento',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _discountValue = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón para agregar/actualizar producto
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addOrUpdateProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditingProduct()
                      ? 'Actualizar Producto'
                      : 'Agregar Producto',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = _calculateSubtotal();
    final discount = _calculateTotalDiscount();
    final total = subtotal - discount;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Bs. ${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Descuento Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('- Bs. ${discount.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Bs. ${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.green600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: AppColors.gray400),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.gray700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppColors.green600,
            ),
            child: const Text(
              'Guardar Pedido',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Métodos auxiliares
  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product['name']
            .toLowerCase()
            .contains(_productSearchController.text.toLowerCase());
        final notSelected = !_selectedProducts.any((p) => p['id'] == product['id']);
        return matchesSearch && notSelected;
      }).toList();
    });
  }

  void _selectProduct(Map<String, dynamic> product) {
    setState(() {
      _selectedProduct = product;
      _productQuantity = 1;
      _productUnitPrice = _paymentMethod == 'Crédito'
          ? product['credit_price'].toDouble()
          : product['cash_price'].toDouble();
      _discountType = 'ninguno';
      _discountValue = 0.0;
      _showProductForm = true;
    });
  }

  void _addOrUpdateProduct() {
    if (_selectedProduct == null) return;

    final subtotal = _productQuantity * _productUnitPrice;
    double discount = 0.0;

    if (_discountType == 'porcentaje') {
      discount = subtotal * (_discountValue / 100);
    } else if (_discountType == 'monto_fijo') {
      discount = _discountValue;
    }

    final product = {
      'id': _selectedProduct!['id'],
      'product_id': _selectedProduct!['product_id'],
      'name': _selectedProduct!['name'],
      'presentation': _selectedProduct!['presentation'],
      'quantity': _productQuantity,
      'unit_price': _productUnitPrice,
      'discount_type': _discountType,
      'discount_value': _discountValue,
      'subtotal': subtotal - discount,
    };

    setState(() {
      if (_isEditingProduct()) {
        // Actualizar producto existente
        final index = _selectedProducts.indexWhere((p) => p['id'] == product['id']);
        _selectedProducts[index] = product;
      } else {
        // Agregar nuevo producto
        _selectedProducts.add(product);
      }

      _showProductForm = false;
      _selectedProduct = null;
      _productSearchController.clear();
      _filterProducts();
    });
  }

  bool _isEditingProduct() {
    if (_selectedProduct == null) return false;
    return _selectedProducts.any((p) => p['id'] == _selectedProduct!['id']);
  }

  void _editProduct(Map<String, dynamic> product) {
    setState(() {
      _selectedProduct = _products.firstWhere(
        (p) => p['id'] == product['id'],
        orElse: () => product,
      );
      _productQuantity = product['quantity'];
      _productUnitPrice = product['unit_price'];
      _discountType = product['discount_type'] ?? 'ninguno';
      _discountValue = product['discount_value'] ?? 0.0;
      _showProductForm = true;
    });
  }

  void _removeProduct(int productId) {
    setState(() {
      _selectedProducts.removeWhere((p) => p['id'] == productId);
      _filterProducts();
    });
  }

  double _calculateSubtotal() {
    return _selectedProducts.fold(
      0.0,
      (sum, product) => sum + product['subtotal'],
    );
  }

  double _calculateTotalDiscount() {
    return _selectedProducts.fold(0.0, (sum, product) {
      if (product['discount_type'] == 'porcentaje') {
        return sum +
            (product['quantity'] *
                product['unit_price'] *
                (product['discount_value'] / 100));
      } else if (product['discount_type'] == 'monto_fijo') {
        return sum + product['discount_value'];
      }
      return sum;
    });
  }

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null && picked != _deliveryDate) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  Future<void> _selectDeliveryTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _deliveryTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _deliveryTime) {
      setState(() {
        _deliveryTime = picked;
      });
    }
  }

  void _updateProductPrices() {
    setState(() {
      for (var product in _selectedProducts) {
        final fullProduct = _products.firstWhere(
          (p) => p['id'] == product['id'],
          orElse: () => product,
        );

        product['unit_price'] = _paymentMethod == 'Crédito'
            ? fullProduct['credit_price']
            : fullProduct['cash_price'];

        // Recalcular subtotal
        final subtotal = product['quantity'] * product['unit_price'];
        double discount = 0.0;

        if (product['discount_type'] == 'porcentaje') {
          discount = subtotal * (product['discount_value'] / 100);
        } else if (product['discount_type'] == 'monto_fijo') {
          discount = product['discount_value'];
        }

        product['subtotal'] = subtotal - discount;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agregue al menos un producto')),
        );
        return;
      }

      if (_deliveryDate == null || _deliveryTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione fecha y hora de entrega')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final orderData = {
          'cliente_id': _selectedClientId,
          'sucursal_id': _selectedBranchId,
          'direccion_entrega': _deliveryAddressController.text,
          'metodo_pago': _paymentMethod,
          'plazo_credito': _paymentMethod == 'Crédito' ? _creditTerm : null,
          'fecha_entrega': DateFormat('yyyy-MM-dd').format(_deliveryDate!),
          'hora_entrega_estimada': '${_deliveryTime!.hour}:${_deliveryTime!.minute}',
          'notas_cliente': _notesController.text,
          'productos': _selectedProducts
              .map(
                (p) => {
                  'id': p['id'],
                  'cantidad': p['quantity'],
                  'precio_unitario': p['unit_price'],
                  'tipo_descuento': p['discount_type'],
                  'valor_descuento': p['discount_value'],
                },
              )
              .toList(),
        };

        final storage = Provider.of<StorageUtil>(context, listen: false);
        final token = await storage.getToken();

        final response = widget.order != null
            ? await http.put(
                Uri.parse('${ApiConstants.baseUrl}/v1/pedidos/${widget.order!['id']}'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: json.encode(orderData),
              )
            : await http.post(
                Uri.parse('${ApiConstants.baseUrl}/v1/pedidos'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: json.encode(orderData),
              );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.order != null
                    ? 'Pedido actualizado correctamente'
                    : 'Pedido creado correctamente',
              ),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context, true); // Retornar true para indicar éxito
            }
          });
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Error al guardar el pedido');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}