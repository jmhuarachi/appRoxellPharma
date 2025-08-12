// lib/services/notifications_service.dart
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationsService with ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Ejemplo de notificaciones iniciales
  void loadSampleNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'Nuevo pedido recibido',
        message:
            'El cliente Farmacia Salud ha realizado un pedido por Bs 345.50',
        icon: Icons.shopping_bag_rounded,
        color: Colors.orange,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2',
        title: 'Pedido en proceso',
        message: 'El pedido #PED-2025-002 está siendo preparado para envío',
        icon: Icons.inventory_rounded,
        color: Colors.blue,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      NotificationModel(
        id: '3',
        title: 'Stock bajo',
        message: 'El producto AMBROXOL tiene stock bajo (15 unidades)',
        icon: Icons.warning_rounded,
        color: Colors.red,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '4',
        title: 'Pedido entregado',
        message: 'El pedido #PED-2025-001 fue entregado con éxito',
        icon: Icons.check_circle_rounded,
        color: Colors.green,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: '5',
        title: 'Nuevo mensaje',
        message: 'Tienes 3 mensajes sin leer del equipo de ventas',
        icon: Icons.email_rounded,
        color: Colors.purple,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }
}
