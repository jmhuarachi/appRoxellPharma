import 'package:flutter/material.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';
import 'package:roxellpharma/core/widgets/notification_badge.dart';


class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onNotificationsPressed;
  final int notificationCount;

  const DashboardAppBar({
    super.key,
    required this.onProfilePressed,
    required this.onNotificationsPressed,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.orange100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: AppColors.orange600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Panel de Control',
            style: TextStyle(
              color: AppColors.gray800,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        _NotificationButton(
          count: notificationCount,
          onPressed: onNotificationsPressed,
        ),
        const SizedBox(width: 8),
        _ProfileButton(onPressed: onProfilePressed),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _NotificationButton({
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: AppColors.gray600,
              size: 20,
            ),
          ),
          onPressed: onPressed,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: NotificationBadge(count: count, size: 16),
          ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ProfileButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Hero(
        tag: 'user_avatar',
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.orange400, AppColors.orange600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange200.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}