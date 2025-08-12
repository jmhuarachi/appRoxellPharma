import 'package:flutter/material.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample list of orders
    final orders = [
      {'id': '001', 'customer': 'John Doe', 'status': 'Pending'},
      {'id': '002', 'customer': 'Jane Smith', 'status': 'Completed'},
      {'id': '003', 'customer': 'Alice Brown', 'status': 'Processing'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(order['id']!),
              ),
              title: Text(order['customer']!),
              subtitle: Text('Status: ${order['status']}'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle order tap
              },
            ),
          );
        },
      ),
    );
  }
}