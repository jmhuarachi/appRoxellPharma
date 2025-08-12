// // lib/screens/admin/widgets/notification_popup.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/costants/app_colors.dart';
// import 'package:flutter_application_1/services/notifications_service.dart';

// class NotificationPopup extends StatefulWidget {
//   final NotificationModel notification;
//   final VoidCallback onDismissed;

//   const NotificationPopup({
//     super.key,
//     required this.notification,
//     required this.onDismissed,
//   });

//   @override
//   State<NotificationPopup> createState() => _NotificationPopupState();
// }

// class _NotificationPopupState extends State<NotificationPopup> {
//   bool _isVisible = true;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() => _isVisible = false);
//         widget.onDismissed();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedPositioned(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//       top: _isVisible ? 16 : -100,
//       left: 16,
//       right: 16,
//       child: Dismissible(
//         key: Key(widget.notification.id),
//         direction: DismissDirection.up,
//         onDismissed: (_) => widget.onDismissed(),
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 20,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: widget.notification.color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     widget.notification.icon,
//                     color: widget.notification.color,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.notification.title,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.gray800,
//                         ),
//                       ),
//                       Text(
//                         widget.notification.message,
//                         style: const TextStyle(
//                           color: AppColors.gray600,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close_rounded, size: 20),
//                   onPressed: () {
//                     setState(() => _isVisible = false);
//                     widget.onDismissed();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }