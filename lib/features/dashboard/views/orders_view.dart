// lib/features/dashboard/views/orders_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';
import 'package:roxellpharma/core/utils/storage_util.dart';
import 'package:roxellpharma/features/auth/presentation/providers/auth_provider.dart';
import 'package:roxellpharma/features/dashboard/orders/presentation/providers/orders_provider.dart';
import 'package:roxellpharma/features/dashboard/orders/presentation/screens/create_edit_order_screen.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, bool> _expandedOrders = {};
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OrdersProvider>(context, listen: false);
      provider.loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return AppColors.yellow600;
      case 'Procesando':
        return AppColors.blue600;
      case 'Enviado':
        return AppColors.indigo600;
      case 'Entregado':
        return AppColors.green600;
      case 'Cancelado':
        return AppColors.red600;
      default:
        return AppColors.gray600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pendiente':
        return Icons.pending_rounded;
      case 'Procesando':
        return Icons.settings;
      case 'Enviado':
        return Icons.local_shipping_rounded;
      case 'Entregado':
        return Icons.check_circle_rounded;
      case 'Cancelado':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'Contado':
        return AppColors.green600;
      case 'Crédito':
        return AppColors.purple600;
      case 'Mixto':
        return AppColors.teal600;
      default:
        return AppColors.gray600;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Contado':
        return Icons.attach_money_rounded;
      case 'Crédito':
        return Icons.credit_card_rounded;
      case 'Mixto':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  

  void _toggleOrderDetails(int orderId) {
    setState(() {
      _expandedOrders[orderId] = !(_expandedOrders[orderId] ?? false);
    });
  }

  void _generateOrderPDF(OrderItem order) {
    // Implement PDF generation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generando PDF para ${order.orderNumber}')),
    );
  }

  void _editOrder(OrderItem order) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CreateEditOrderScreen(order: order.toMap()), // Convertir a Map
    ),
  );
}

  void _changeOrderStatus(OrderItem order) {
    final provider = Provider.of<OrdersProvider>(context, listen: false);
    String? newStatus = order.estado;
    String? reason;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar Estado del Pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seleccione el nuevo estado:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: newStatus,
                items: [
                  'Pendiente',
                  'Procesando',
                  'Enviado',
                  'Entregado',
                  'Cancelado',
                ].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  newStatus = value;
                },
              ),
              if (newStatus == 'Cancelado') ...[
                const SizedBox(height: 16),
                const Text('Razón de cancelación:'),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => reason = value,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese la razón de cancelación',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await provider.updateOrderStatus(order.id, newStatus!, notas: reason);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteOrder(OrderItem order) {
    final provider = Provider.of<OrdersProvider>(context, listen: false);
    String? reason;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Está seguro de eliminar el pedido ${order.orderNumber}?'),
              const SizedBox(height: 16),
              const Text('Esta acción no se puede deshacer.'),
              const SizedBox(height: 16),
              const Text('Razón de eliminación:'),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => reason = value,
                decoration: const InputDecoration(
                  hintText: 'Ingrese la razón de eliminación',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await provider.deleteOrder(order.id);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red600,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.gray500),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppColors.gray500, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(OrdersProvider provider) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por número de pedido, cliente o NIT...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              provider.setSearchQuery(value);
              provider.loadOrders();
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
            backgroundColor: _showAdvancedFilters 
                ? AppColors.orange600 
                : AppColors.gray200,
            foregroundColor: _showAdvancedFilters 
                ? Colors.white 
                : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            _searchController.clear();
            provider.setSearchQuery('');
            provider.setStatus('todos');
            provider.setPaymentMethod('todos');
            provider.setDateRange('todos');
            provider.loadOrders();
          },
          icon: const Icon(Icons.refresh),
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

  Widget _buildAdvancedFilters(OrdersProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Status Filter
          DropdownButtonFormField<String>(
            value: provider.selectedStatus,
            decoration: InputDecoration(
              labelText: 'Estado del Pedido',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              {'value': 'todos', 'label': 'Todos'},
              {'value': 'Pendiente', 'label': 'Pendiente'},
              {'value': 'Procesando', 'label': 'Procesando'},
              {'value': 'Enviado', 'label': 'Enviado'},
              {'value': 'Entregado', 'label': 'Entregado'},
              {'value': 'Cancelado', 'label': 'Cancelado'},
            ].map((status) {
              return DropdownMenuItem<String>(
                value: status['value'],
                child: Text(status['label']!),
              );
            }).toList(),
            onChanged: (value) {
              provider.setStatus(value!);
              provider.loadOrders();
            },
          ),
          const SizedBox(height: 16),

          // Payment Method Filter
          DropdownButtonFormField<String>(
            value: provider.selectedPaymentMethod,
            decoration: InputDecoration(
              labelText: 'Método de Pago',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              {'value': 'todos', 'label': 'Todos'},
              {'value': 'Contado', 'label': 'Contado'},
              {'value': 'Crédito', 'label': 'Crédito'},
              {'value': 'Mixto', 'label': 'Mixto'},
            ].map((method) {
              return DropdownMenuItem<String>(
                value: method['value'],
                child: Text(method['label']!),
              );
            }).toList(),
            onChanged: (value) {
              provider.setPaymentMethod(value!);
              provider.loadOrders();
            },
          ),
          const SizedBox(height: 16),

          // Date Range Filter
          // DropdownButtonFormField<String>(
          //   value: provider.selectedDateRange,
          //   decoration: InputDecoration(
          //     labelText: 'Rango de Fechas',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          //   items: [
          //     {'value': 'todos', 'label': 'Todos'},
          //     {'value': 'hoy', 'label': 'Hoy'},
          //     {'value': 'semana', 'label': 'Esta semana'},
          //     {'value': 'mes', 'label': 'Este mes'},
          //     {'value': 'personalizado', 'label': 'Personalizado'},
          //   ].map((range) {
          //     return DropdownMenuItem<String>(
          //       value: range['value'],
          //       child: Text(range['label']!),
          //     );
          //   }).toList(),
          //   onChanged: (value) {
          //     provider.setDateRange(value!);
          //     provider.loadOrders();
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrdersProvider provider) {
    if (provider.isLoading && provider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No se encontraron pedidos que coincidan con los criterios de búsqueda',
            style: TextStyle(color: AppColors.gray500, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.orders.length,
      itemBuilder: (context, index) {
        final order = provider.orders[index];
        final isExpanded = _expandedOrders[order.id] ?? false;

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
                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${order.clienteNombre} (NIT: ${order.clienteNit})',
                            style: TextStyle(
                              color: AppColors.gray500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.store,
                                size: 16,
                                color: AppColors.gray400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.sucursalNombre,
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

                    // Order Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\Bs${order.montoTotalFinal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Status Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.estado).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(order.estado),
                                    size: 14,
                                    color: _getStatusColor(order.estado),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.estado,
                                    style: TextStyle(
                                      color: _getStatusColor(order.estado),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Payment Method Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getPaymentMethodColor(order.metodoPago).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getPaymentMethodIcon(order.metodoPago),
                                    size: 14,
                                    color: _getPaymentMethodColor(order.metodoPago),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.metodoPago,
                                    style: TextStyle(
                                      color: _getPaymentMethodColor(order.metodoPago),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (order.metodoPago == 'Crédito' && order.plazoCredito != null)
                                    Text(
                                      ' (${order.plazoCredito}d)',
                                      style: TextStyle(
                                        color: _getPaymentMethodColor(order.metodoPago),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _toggleOrderDetails(order.id),
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                      color: AppColors.blue600,
                    ),
                    IconButton(
                      onPressed: () => _generateOrderPDF(order),
                      icon: const Icon(Icons.picture_as_pdf),
                      color: AppColors.blue600,
                    ),
                    IconButton(
                      onPressed: () => _editOrder(order),
                      icon: const Icon(Icons.edit),
                      color: AppColors.blue600,
                    ),
                    IconButton(
                      onPressed: () => _changeOrderStatus(order),
                      icon: const Icon(Icons.swap_vert),
                      color: AppColors.green600,
                    ),
                    IconButton(
                      onPressed: () => _deleteOrder(order),
                      icon: const Icon(Icons.delete),
                      color: AppColors.red600,
                    ),
                  ],
                ),

                // Order Details
                if (isExpanded) ...[
                  const Divider(),
                  const SizedBox(height: 8),

                  // Order Information
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    children: [
                      _buildDetailItem(
                        'Fecha Pedido',
                        DateFormat('dd/MM/yyyy').format(order.fechaPedido),
                        icon: Icons.calendar_today,
                      ),
                      _buildDetailItem(
                        'Fecha Entrega',
                        '${DateFormat('dd/MM/yyyy').format(order.fechaEntrega ?? order.fechaPedido)} ${order.horaEntregaEstimada ?? ''}',
                        icon: Icons.calendar_today,
                      ),
                      _buildDetailItem(
                        'Dirección Entrega',
                        order.direccionEntrega,
                        icon: Icons.location_on,
                      ),
                      _buildDetailItem(
                        'Vendedor',
                        order.vendedorNombre ?? 'No asignado',
                        icon: Icons.person,
                      ),
                      _buildDetailItem(
                        'Notas',
                        order.notasCliente ?? 'Ninguna',
                        icon: Icons.notes,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Products List
                  const Text(
                    'Productos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  Table(
                    border: TableBorder.all(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    children: [
                      // Header
                      const TableRow(
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Producto',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Cantidad',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Precio Unitario',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Subtotal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      // Products
                      ...order.productos.map<TableRow>((product) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${product.nombre}\n${product.presentacion}',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product.cantidad.toString(),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '\Bs${product.precioUnitario.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '\Bs${product.subtotal.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      // Footer
                      TableRow(
                        decoration: const BoxDecoration(
                          color: AppColors.gray100,
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(''),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(''),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '\Bs${order.montoTotalFinal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrdersProvider>(context);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    // Calculate statistics
    final pendingCount = provider.orders
        .where((o) => o.estado == 'Pendiente')
        .length;
    final processingCount = provider.orders
        .where((o) => o.estado == 'Procesando')
        .length;
    final deliveredCount = provider.orders
        .where((o) => o.estado == 'Entregado')
        .length;
    final canceledCount = provider.orders
        .where((o) => o.estado == 'Cancelado')
        .length;
    final totalAmount = provider.orders.fold(
      0.0,
      (sum, order) => sum + order.montoTotalFinal,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadOrders();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       _buildStatCard(
              //         'Total Pedidos',
              //         provider.totalItems.toString(),
              //         Icons.shopping_bag_rounded,
              //         AppColors.blue500,
              //       ),
              //       const SizedBox(width: 12),
              //       _buildStatCard(
              //         'Valor Total',
              //         '\Bs${totalAmount.toStringAsFixed(2)}',
              //         Icons.attach_money_rounded,
              //         AppColors.green600,
              //       ),
              //       const SizedBox(width: 12),
              //       _buildStatCard(
              //         'Pendientes',
              //         pendingCount.toString(),
              //         Icons.pending_rounded,
              //         AppColors.yellow600,
              //       ),
              //       const SizedBox(width: 12),
              //       _buildStatCard(
              //         'Cancelados',
              //         canceledCount.toString(),
              //         Icons.cancel_rounded,
              //         AppColors.red600,
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 20),

              // Search and Filters
              _buildSearchAndFilters(provider),
              const SizedBox(height: 16),

              // Advanced Filters
              if (_showAdvancedFilters) _buildAdvancedFilters(provider),

              // Orders List
              _buildOrdersList(provider),

              // Pagination
              if (provider.totalItems > provider.itemsPerPage)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: provider.currentPage > 1
                            ? () {
                                provider.setPage(provider.currentPage - 1);
                                provider.loadOrders();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        'Página ${provider.currentPage} de ${(provider.totalItems / provider.itemsPerPage).ceil()}',
                      ),
                      IconButton(
                        onPressed: provider.currentPage * provider.itemsPerPage < provider.totalItems
                            ? () {
                                provider.setPage(provider.currentPage + 1);
                                provider.loadOrders();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: (user?.isAdmin ?? false) || (user?.isSuperAdmin ?? false)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEditOrderScreen(),
                  ),
                );
              },
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
}