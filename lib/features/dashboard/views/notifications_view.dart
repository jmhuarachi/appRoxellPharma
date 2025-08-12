// lib/screens/admin/widgets/views/notifications_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';
import 'package:roxellpharma/core/services/notifications_service.dart';
import 'package:roxellpharma/features/dashboard/notifications/presentation/widgets/notification_item.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationsService = Provider.of<NotificationsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_as_unread_rounded),
            onPressed: () {
              notificationsService.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')),
              );
            },
            tooltip: 'Marcar todas como leídas',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              notificationsService.clearAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todas las notificaciones eliminadas')),
              );
            },
            tooltip: 'Limpiar todas',
          ),
        ],
      ),
      body: notificationsService.notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_rounded, size: 64, color: AppColors.gray400),
                  SizedBox(height: 16),
                  Text(
                    'No hay notificaciones',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificationsService.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationsService.notifications[index];
                return NotificationItem(
                  notification: notification,
                  onTap: () {
                    notificationsService.markAsRead(notification.id);
                    // Aquí puedes navegar a la pantalla relevante
                  },
                );
              },
            ),
    );
  }
}