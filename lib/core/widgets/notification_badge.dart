// lib/screens/admin/widgets/notification_badge.dart
import 'package:flutter/material.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final double size;
  final Color? color;

  const NotificationBadge({
    super.key,
    required this.count,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.red600,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 9 ? '9+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}