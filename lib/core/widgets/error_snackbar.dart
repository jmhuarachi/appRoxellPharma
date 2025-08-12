// lib/core/widgets/error_snackbar.dart
// lib/core/widgets/error_snackbar.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ErrorSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Programar el snackbar para mostrarse después del frame actual
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: duration,
          ),
        );
      }
    });
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Programar el snackbar para mostrarse después del frame actual
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: duration,
          ),
        );
      }
    });
  }

  // Método alternativo para mostrar snackbars inmediatamente 
  // (solo usar cuando estés seguro de que no estás en build)
  static void showImmediate({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor ?? Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: duration,
        ),
      );
    }
  }

  static void showSuccessImmediate({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showImmediate(
      context: context,
      message: message,
      duration: duration,
      backgroundColor: Colors.green,
    );
  }
}