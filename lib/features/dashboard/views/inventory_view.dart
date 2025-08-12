import 'package:flutter/material.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStockStatus = 'all';
  String _selectedBranch = 'all';
  bool _showAdvancedFilters = false;
  //bool _isLoading = false;

  // Mock data - replace with your API calls
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      "id": 1,
      "productId": 101,
      "productName": "AMBROXOL",
      "composition": "Ambroxol Clorhidrato 30 mg",
      "branchId": 1,
      "branchName": "La Paz",
      "stock": 15,
      "minStock": 20,
      "maxStock": 100,
      "cashPrice": 22.50,
      "creditPrice": 25.00,
      "movements": [
        {
          "date": "27/7/2025, 12:28:29 p.m.",
          "type": "Transferencia",
          "description":
              "Transferencia de 20 unidades desde La Paz hacia Cochabamba",
          "quantity": -20,
          "responsible": "Sistema",
          "notes": "Integran",
        },
        {
          "date": "27/7/2025, 12:28:29 p.m.",
          "type": "Transferencia",
          "description":
              "Transferencia de 20 unidades desde Cochabamba hacia La Paz",
          "quantity": 20,
          "responsible": "Sistema",
          "notes": "Integran",
        },
      ],
    },
    {
      "id": 2,
      "productId": 102,
      "productName": "AMOXICILINA",
      "composition": "Amoxicilina 250 mg",
      "branchId": 1,
      "branchName": "La Paz",
      "stock": 275,
      "minStock": 50,
      "maxStock": 300,
      "cashPrice": 15.00,
      "creditPrice": 18.00,
      "movements": [],
    },
    {
      "id": 3,
      "productId": 103,
      "productName": "AZITROXELL",
      "composition": "Azitromicina 500 mg",
      "branchId": 2,
      "branchName": "Cochabamba",
      "stock": 45,
      "minStock": 30,
      "maxStock": 150,
      "cashPrice": 85.00,
      "creditPrice": 90.00,
      "movements": [
        {
          "date": "28/7/2025, 10:15:22 a.m.",
          "type": "Compra",
          "description": "Compra de 50 unidades a proveedor PharmaCorp",
          "quantity": 50,
          "responsible": "Juan Pérez",
          "notes": "Factura #PH-2025-789",
        },
      ],
    },
    {
      "id": 4,
      "productId": 104,
      "productName": "GASTROXELL",
      "composition": "Omeprazol 20 mg",
      "branchId": 1,
      "branchName": "La Paz",
      "stock": 320,
      "minStock": 100,
      "maxStock": 500,
      "cashPrice": 1.80,
      "creditPrice": 2.00,
      "movements": [],
    },
    {
      "id": 5,
      "productId": 105,
      "productName": "DOLO-XELL",
      "composition": "Salicilato de Metilo-Alcanfor-Mentol",
      "branchId": 3,
      "branchName": "Santa Cruz",
      "stock": 18,
      "minStock": 15,
      "maxStock": 50,
      "cashPrice": 12.50,
      "creditPrice": 15.00,
      "movements": [
        {
          "date": "29/7/2025, 03:45:10 p.m.",
          "type": "Venta",
          "description": "Venta a cliente particular",
          "quantity": -2,
          "responsible": "María Gómez",
          "notes": "Recibo #SC-00254",
        },
      ],
    },
    {
      "id": 6,
      "productId": 106,
      "productName": "NITROFURAZONA",
      "composition": "Nitrofurazona 0.2 g",
      "branchId": 2,
      "branchName": "Cochabamba",
      "stock": 22,
      "minStock": 10,
      "maxStock": 40,
      "cashPrice": 18.00,
      "creditPrice": 20.00,
      "movements": [],
    },
    {
      "id": 7,
      "productId": 107,
      "productName": "PROFEROX 200",
      "composition": "Ketoprofeno 200 mg",
      "branchId": 1,
      "branchName": "La Paz",
      "stock": 150,
      "minStock": 50,
      "maxStock": 300,
      "cashPrice": 0.80,
      "creditPrice": 1.00,
      "movements": [
        {
          "date": "30/7/2025, 09:30:45 a.m.",
          "type": "Ajuste",
          "description": "Ajuste de inventario por conteo físico",
          "quantity": 5,
          "responsible": "Sistema",
          "notes": "Diferencia detectada en inventario",
        },
      ],
    },
    {
      "id": 8,
      "productId": 108,
      "productName": "TRIMESOL FORTE",
      "composition": "Cotrimoxazol 800mg + 160mg",
      "branchId": 3,
      "branchName": "Santa Cruz",
      "stock": 420,
      "minStock": 200,
      "maxStock": 600,
      "cashPrice": 0.50,
      "creditPrice": 0.60,
      "movements": [],
    },
    {
      "id": 9,
      "productId": 109,
      "productName": "KETEROX",
      "composition": "Ketorolaco 20 mg",
      "branchId": 2,
      "branchName": "Cochabamba",
      "stock": 180,
      "minStock": 100,
      "maxStock": 300,
      "cashPrice": 0.75,
      "creditPrice": 0.90,
      "movements": [
        {
          "date": "31/7/2025, 11:20:33 a.m.",
          "type": "Transferencia",
          "description":
              "Transferencia de 30 unidades desde Cochabamba hacia La Paz",
          "quantity": -30,
          "responsible": "Sistema",
          "notes": "Orden #TR-2025-456",
        },
      ],
    },
    {
      "id": 10,
      "productId": 110,
      "productName": "POVIDONA YODADA",
      "composition": "Povidona Yodada 10%",
      "branchId": 1,
      "branchName": "La Paz",
      "stock": 25,
      "minStock": 20,
      "maxStock": 60,
      "cashPrice": 25.00,
      "creditPrice": 28.00,
      "movements": [],
    },
    {
      "id": 11,
      "productId": 111,
      "productName": "LORALGEX",
      "composition": "Desloratadina 2.5mg/5ml",
      "branchId": 3,
      "branchName": "Santa Cruz",
      "stock": 35,
      "minStock": 20,
      "maxStock": 80,
      "cashPrice": 45.00,
      "creditPrice": 50.00,
      "movements": [
        {
          "date": "1/8/2025, 04:15:55 p.m.",
          "type": "Venta",
          "description": "Venta a farmacia asociada",
          "quantity": -10,
          "responsible": "Carlos Rojas",
          "notes": "Factura #FA-2025-789",
        },
      ],
    },
    {
      "id": 12,
      "productId": 112,
      "productName": "NORMOGLIN",
      "composition": "Metformina 850 mg",
      "branchId": 2,
      "branchName": "Cochabamba",
      "stock": 200,
      "minStock": 40,
      "maxStock": 120,
      "cashPrice": 1.20,
      "creditPrice": 1.50,
      "movements": [],
    },
  ];

  final List<Map<String, String>> _stockStatusOptions = [
    {'value': 'all', 'label': 'Todos'},
    {'value': 'critical', 'label': 'Crítico'},
    {'value': 'low', 'label': 'Bajo'},
    {'value': 'normal', 'label': 'Normal'},
    {'value': 'high', 'label': 'Alto'},
  ];

  final List<Map<String, dynamic>> _branches = [
    {'id': 1, 'name': 'La Paz'},
    {'id': 2, 'name': 'Cochabamba'},
    {'id': 3, 'name': 'Santa Cruz'},
    {'id': 4, 'name': 'Oruro'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Gestión de Inventario'),
      //   backgroundColor: AppColors.orange600,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            // _buildStatisticsCards(),
            const SizedBox(height: 20),

            // Search and Filters
            _buildSearchAndFilters(),
            const SizedBox(height: 16),

            // Advanced Filters
            if (_showAdvancedFilters) _buildAdvancedFilters(),

            // Inventory List
            _buildInventoryList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddInventoryDialog,
        backgroundColor: AppColors.orange600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget _buildStatisticsCards() {
  //   final criticalCount = _inventoryItems
  //       .where((item) => _getStockStatus(item) == 'critical')
  //       .length;
  //   final lowCount = _inventoryItems
  //       .where((item) => _getStockStatus(item) == 'low')
  //       .length;

  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       children: [
  //         StatCard(
  //           title: 'Total Productos',
  //           value: _inventoryItems.length.toString(),
  //           icon: Icons.inventory_2_rounded,
  //           color: AppColors.blue500,
  //         ),
  //         const SizedBox(width: 12),
  //         StatCard(
  //           title: 'Stock Crítico',
  //           value: criticalCount.toString(),
  //           icon: Icons.warning_rounded,
  //           color: AppColors.red600,
  //         ),
  //         const SizedBox(width: 12),
  //         StatCard(
  //           title: 'Stock Bajo',
  //           value: lowCount.toString(),
  //           icon: Icons.trending_down_rounded,
  //           color: AppColors.yellow600,
  //         ),
  //         const SizedBox(width: 12),
  //         StatCard(
  //           title: 'Sucursales',
  //           value: _branches.length.toString(),
  //           icon: Icons.store_rounded,
  //           color: AppColors.green600,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              // Implement search functionality
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () {
            setState(() {
              _showAdvancedFilters = !_showAdvancedFilters;
            });
          },
          icon: const Icon(Icons.filter_alt_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.gray200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Stock Status Filter
          DropdownButtonFormField<String>(
            value: _selectedStockStatus,
            decoration: InputDecoration(
              labelText: 'Estado de Stock',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _stockStatusOptions.map((status) {
              return DropdownMenuItem<String>(
                value: status['value'],
                child: Text(status['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStockStatus = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Branch Filter
          DropdownButtonFormField<String>(
            value: _selectedBranch,
            decoration: InputDecoration(
              labelText: 'Sucursal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: 'all',
                child: Text('Todas las sucursales'),
              ),
              ..._branches.map((branch) {
                return DropdownMenuItem<String>(
                  value: branch['id'].toString(),
                  child: Text(branch['name']),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedBranch = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList() {
    final filteredItems = _inventoryItems.where((item) {
      // Apply filters
      final matchesSearch = item['productName']
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());

      final matchesStockStatus =
          _selectedStockStatus == 'all' ||
          _getStockStatus(item) == _selectedStockStatus;

      final matchesBranch =
          _selectedBranch == 'all' ||
          item['branchId'].toString() == _selectedBranch;

      return matchesSearch && matchesStockStatus && matchesBranch;
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No se encontraron productos que coincidan con los criterios de búsqueda',
            style: TextStyle(color: AppColors.gray500, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final stockStatus = _getStockStatus(item);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['productName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item['composition'],
                            style: TextStyle(
                              color: AppColors.gray500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.gray400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['branchName'],
                                style: TextStyle(
                                  color: AppColors.gray500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Stock Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['stock'].toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Stock Actual',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    // Status Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStockStatusColor(
                          stockStatus,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStockStatusIcon(stockStatus),
                            size: 16,
                            color: _getStockStatusColor(stockStatus),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStockStatusText(stockStatus),
                            style: TextStyle(
                              color: _getStockStatusColor(stockStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _showEditInventoryDialog(item),
                      icon: const Icon(Icons.edit),
                      color: AppColors.blue600,
                    ),
                    IconButton(
                      onPressed: () => _showTransferDialog(item),
                      icon: const Icon(Icons.swap_horiz),
                      color: AppColors.purple600,
                    ),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(item),
                      icon: const Icon(Icons.delete),
                      color: AppColors.red600,
                    ),
                  ],
                ),

                // Details Section
                ExpansionTile(
                  title: const Text('Ver detalles'),
                  children: [
                    // Stock Info Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2,
                      children: [
                        _buildDetailItem(
                          'Stock Mínimo',
                          item['minStock'].toString(),
                        ),
                        _buildDetailItem(
                          'Stock Máximo',
                          item['maxStock'].toString(),
                        ),
                        _buildDetailItem(
                          'Precio Contado',
                          'Bs. ${item['cashPrice'].toStringAsFixed(2)}',
                        ),
                        _buildDetailItem(
                          'Precio Crédito',
                          'Bs. ${item['creditPrice'].toStringAsFixed(2)}',
                        ),
                        _buildDetailItem(
                          '% Disponible',
                          '${((item['stock'] / item['maxStock']) * 100).toStringAsFixed(0)}%',
                          showProgress: true,
                          progressValue: item['stock'] / item['maxStock'],
                        ),
                      ],
                    ),

                    // Movement History
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Historial de Movimientos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    if (item['movements'].isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No hay movimientos registrados para este producto',
                        ),
                      )
                    else
                      ...item['movements'].map<Widget>((movement) {
                        return ListTile(
                          title: Text(movement['description']),
                          subtitle: Text(
                            '${movement['date']} - ${movement['responsible']}',
                          ),
                          trailing: Text(
                            '${movement['quantity']} unidades',
                            style: TextStyle(
                              color: movement['type'] == 'Transferencia'
                                  ? AppColors.blue600
                                  : AppColors.red600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(
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
          Text(title, style: TextStyle(color: AppColors.gray500, fontSize: 14)),
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

  String _getStockStatus(Map<String, dynamic> item) {
    if (item['stock'] <= item['minStock']) return 'critical';
    if (item['stock'] <= item['minStock'] * 1.5) return 'low';
    if (item['stock'] >= item['maxStock'] * 0.8) return 'high';
    return 'normal';
  }

  Color _getStockStatusColor(String status) {
    switch (status) {
      case 'critical':
        return AppColors.red600;
      case 'low':
        return AppColors.yellow600;
      case 'high':
        return AppColors.blue600;
      case 'normal':
      default:
        return AppColors.green600;
    }
  }

  IconData _getStockStatusIcon(String status) {
    switch (status) {
      case 'critical':
        return Icons.warning;
      case 'low':
        return Icons.trending_down;
      case 'high':
        return Icons.trending_up;
      case 'normal':
      default:
        return Icons.check_circle;
    }
  }

  String _getStockStatusText(String status) {
    switch (status) {
      case 'critical':
        return 'Crítico';
      case 'low':
        return 'Bajo';
      case 'high':
        return 'Alto';
      case 'normal':
      default:
        return 'Normal';
    }
  }

  void _showAddInventoryDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _productController = TextEditingController();
    final TextEditingController _stockController = TextEditingController();
    final TextEditingController _minStockController = TextEditingController();
    final TextEditingController _maxStockController = TextEditingController();
    final TextEditingController _cashPriceController = TextEditingController();
    final TextEditingController _creditPriceController =
        TextEditingController();

    String? _selectedBranch;
    //String? _selectedProduct;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Nuevo Inventario'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Buscador de Productos
                      TextFormField(
                        controller: _productController,
                        decoration: InputDecoration(
                          labelText: 'Buscar Producto',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          // Implementar búsqueda de productos
                        },
                      ),
                      SizedBox(height: 16),

                      // Selector de Sucursal
                      DropdownButtonFormField<String>(
                        value: _selectedBranch,
                        decoration: InputDecoration(
                          labelText: 'Sucursal',
                          border: OutlineInputBorder(),
                        ),
                        items: _branches.map((branch) {
                          return DropdownMenuItem<String>(
                            value: branch['id'].toString(),
                            child: Text(branch['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione una sucursal';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Stock Inicial
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: 'Stock Inicial',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el stock inicial';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingrese un número válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

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
                      SizedBox(height: 16),

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
                          if (_minStockController.text.isNotEmpty &&
                              int.tryParse(value)! <
                                  int.tryParse(_minStockController.text)!) {
                            return 'Debe ser mayor que el stock mínimo';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

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
                      SizedBox(height: 16),

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
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.gray600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Crear nuevo item de inventario
                      final newItem = {
                        'id': _inventoryItems.length + 1,
                        'productId': 100 + _inventoryItems.length + 1,
                        'productName':
                            'Nuevo Producto', // Esto debería venir de la selección
                        'composition': 'Composición',
                        'branchId': int.parse(_selectedBranch!),
                        'branchName': _branches.firstWhere(
                          (b) => b['id'].toString() == _selectedBranch,
                        )['name'],
                        'stock': int.parse(_stockController.text),
                        'minStock': int.parse(_minStockController.text),
                        'maxStock': int.parse(_maxStockController.text),
                        'cashPrice': double.parse(_cashPriceController.text),
                        'creditPrice': double.parse(
                          _creditPriceController.text,
                        ),
                        'movements': [],
                      };

                      // Actualizar el estado
                      setState(() {
                        _inventoryItems.add(newItem);
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Nuevo inventario creado correctamente',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green600,
                  ),
                  child: Text(
                    'Crear Inventario',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditInventoryDialog(Map<String, dynamic> item) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _stockController = TextEditingController(
      text: item['stock'].toString(),
    );
    final TextEditingController _minStockController = TextEditingController(
      text: item['minStock'].toString(),
    );
    final TextEditingController _maxStockController = TextEditingController(
      text: item['maxStock'].toString(),
    );
    final TextEditingController _cashPriceController = TextEditingController(
      text: item['cashPrice'].toStringAsFixed(2),
    );
    final TextEditingController _creditPriceController = TextEditingController(
      text: item['creditPrice'].toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar ${item['productName']}'),
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
                        return 'Por favor ingrese el stock';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

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
                        return 'Por favor ingrese el stock mínimo';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

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
                        return 'Por favor ingrese el stock máximo';
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
                  SizedBox(height: 16),

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
                        return 'Por favor ingrese el precio';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

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
                        return 'Por favor ingrese el precio';
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
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.gray600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Aquí iría la lógica para guardar los cambios
                  final updatedItem = {
                    ...item,
                    'stock': int.parse(_stockController.text),
                    'minStock': int.parse(_minStockController.text),
                    'maxStock': int.parse(_maxStockController.text),
                    'cashPrice': double.parse(_cashPriceController.text),
                    'creditPrice': double.parse(_creditPriceController.text),
                  };

                  // Actualizar el estado
                  setState(() {
                    final index = _inventoryItems.indexWhere(
                      (i) => i['id'] == item['id'],
                    );
                    if (index != -1) {
                      _inventoryItems[index] = updatedItem;
                    }
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Inventario actualizado correctamente'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue600,
              ),
              child: Text(
                'Guardar Cambios',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTransferDialog(Map<String, dynamic> item) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _quantityController = TextEditingController();
    final TextEditingController _notesController = TextEditingController();

    String? _selectedDestinationBranch;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Transferir ${item['productName']}'),
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
                          hintText: 'Máximo: ${item['stock']}',
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
                          if (int.parse(value) > item['stock']) {
                            return 'No hay suficiente stock';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Sucursal Destino
                      DropdownButtonFormField<String>(
                        value: _selectedDestinationBranch,
                        decoration: InputDecoration(
                          labelText: 'Sucursal Destino',
                          border: OutlineInputBorder(),
                        ),
                        items: _branches
                            .where((branch) => branch['id'] != item['branchId'])
                            .map((branch) {
                              return DropdownMenuItem<String>(
                                value: branch['id'].toString(),
                                child: Text(branch['name']),
                              );
                            })
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDestinationBranch = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione una sucursal destino';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

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
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.gray600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Crear movimiento de transferencia
                      final transfer = {
                        'date': DateTime.now().toString(),
                        'type': 'Transferencia',
                        'description':
                            'Transferencia de ${_quantityController.text} unidades desde ${item['branchName']} hacia ${_branches.firstWhere((b) => b['id'].toString() == _selectedDestinationBranch)['name']}',
                        'quantity': int.parse(_quantityController.text),
                        'responsible': 'Usuario Actual',
                        'notes': _notesController.text.isNotEmpty
                            ? _notesController.text
                            : null,
                      };

                      // Actualizar el estado
                      setState(() {
                        // Reducir stock en origen
                        final originIndex = _inventoryItems.indexWhere(
                          (i) => i['id'] == item['id'],
                        );
                        if (originIndex != -1) {
                          _inventoryItems[originIndex]['stock'] -= int.parse(
                            _quantityController.text,
                          );
                          _inventoryItems[originIndex]['movements'].insert(
                            0,
                            transfer,
                          );
                        }

                        // Buscar si ya existe en destino
                        final destinationIndex = _inventoryItems.indexWhere(
                          (i) =>
                              i['productId'] == item['productId'] &&
                              i['branchId'] ==
                                  int.parse(_selectedDestinationBranch!),
                        );

                        if (destinationIndex != -1) {
                          // Aumentar stock en destino existente
                          _inventoryItems[destinationIndex]['stock'] +=
                              int.parse(_quantityController.text);
                          _inventoryItems[destinationIndex]['movements'].insert(
                            0,
                            transfer,
                          );
                        } else {
                          // Crear nuevo registro en destino
                          final newItem = {
                            'id': _inventoryItems.length + 1,
                            'productId': item['productId'],
                            'productName': item['productName'],
                            'composition': item['composition'],
                            'branchId': int.parse(_selectedDestinationBranch!),
                            'branchName': _branches.firstWhere(
                              (b) =>
                                  b['id'].toString() ==
                                  _selectedDestinationBranch,
                            )['name'],
                            'stock': int.parse(_quantityController.text),
                            'minStock': item['minStock'],
                            'maxStock': item['maxStock'],
                            'cashPrice': item['cashPrice'],
                            'creditPrice': item['creditPrice'],
                            'movements': [transfer],
                          };
                          _inventoryItems.add(newItem);
                        }
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Transferencia realizada correctamente',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange600,
                  ),
                  child: Text(
                    'Confirmar Transferencia',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> item) {
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
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Producto: ${item['productName']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Sucursal: ${item['branchName']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              if (item['stock'] > 0)
                Text(
                  '⚠️ Advertencia: Este producto tiene ${item['stock']} unidades en stock.',
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
                // Eliminar el producto
                setState(() {
                  _inventoryItems.removeWhere((i) => i['id'] == item['id']);
                });

                Navigator.pop(context);

                // Mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Producto eliminado correctamente',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.green600,
                    duration: Duration(seconds: 2),
                  ),
                );
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
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? percentage;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: AppColors.gray500, fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (percentage != null)
                Text(
                  percentage!,
                  style: TextStyle(
                    color: percentage!.startsWith('+')
                        ? AppColors.green600
                        : AppColors.red600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
