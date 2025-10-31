import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../appcolors/app_colors.dart';

class HelperSnackBar {
  static final Set<String> _activeSnackbars = {};

  static Future<void> _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) async {
    final key = '$title-$message';

    // Don't show duplicate snackbars
    if (_activeSnackbars.contains(key)) return;

    _activeSnackbars.add(key);

    // Show the snackbar
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      borderRadius: 12,
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      colorText: Colors.white,
      duration: duration,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      onTap: (_) => Get.back(),
      barBlur: 10,
      overlayBlur: 0,
      dismissDirection: DismissDirection.horizontal,
    );

    // Wait for the snackbar to be shown
    await Future.delayed(const Duration(milliseconds: 100));

    // Use a timer to remove the key when snackbar is closed
    Future.delayed(duration, () {
      _activeSnackbars.remove(key);
    });
  }

  static Future<void> success(String message, {Duration? duration}) async {
    _showSnackbar(
      title: 'Success',
      message: message,
      backgroundColor: Colors.green,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static Future<void> error(String message, {Duration? duration}) async {
    _showSnackbar(
      title: 'Error',
      message: message,
      backgroundColor: AppColors.redColor,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  static Future<void> info(String message, {Duration? duration}) async {
    _showSnackbar(
      title: 'Info',
      message: message,
      backgroundColor: Colors.cyan.shade700,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static Future<void> warning(String message, {Duration? duration}) async {
    _showSnackbar(
      title: 'Warning',
      message: message,
      backgroundColor: Colors.orange.shade700,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  // Deprecated - kept for backward compatibility
  @Deprecated('Use HelperSnackBar.success() or other specific methods instead')
  static SnackbarController snackBar(String title, String message) {
    // Create and show the snackbar directly
    switch (title.toLowerCase()) {
      case 'success':
        success(message);
        break;
      case 'error':
        error(message);
        break;
      case 'warning':
        warning(message);
        break;
      default:
        info(message);
    }

    // Return a dummy controller
    return GetSnackBar(
      title: title,
      message: message,
      snackPosition: SnackPosition.TOP,
    ) as SnackbarController;
  }
}
