import 'package:flutter/material.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:roxellpharma/core/services/notifications_service.dart';
import 'package:roxellpharma/core/widgets/app_bar.dart';
import 'package:roxellpharma/core/widgets/bottom_nav_bar.dart';
import 'package:roxellpharma/core/widgets/user_profile_sheet.dart';
import 'package:roxellpharma/features/dashboard/views/home_view.dart';
import 'package:roxellpharma/features/dashboard/views/inventory_view.dart';
import 'package:roxellpharma/features/dashboard/views/notifications_view.dart';
import 'package:roxellpharma/features/dashboard/views/orders_view.dart';
import 'package:roxellpharma/features/dashboard/views/settings_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
  super.initState();
  _initAnimations();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final notificationsService = Provider.of<NotificationsService>(context, listen: false);
    notificationsService.loadSampleNotifications();
  });
}

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Widget> _widgetOptions = const [
    HomeView(),
    InventoryView(),
    OrdersView(),
    SettingsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _showUserProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const UserProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsService = Provider.of<NotificationsService>(
      context,
      listen: true,
    );
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: DashboardAppBar(
        onProfilePressed: _showUserProfile,
        onNotificationsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsView()),
          );
        },
        notificationCount: notificationsService.unreadCount,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          );
        },
      ),
      bottomNavigationBar: DashboardBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
