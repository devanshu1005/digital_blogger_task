import 'package:flutter/material.dart';

class DialogHelper {
  static void showError(BuildContext context, String message, {String title = 'Error', Color? backgroundColor}) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: backgroundColor ?? Colors.red.shade600,
    );
  }

  static void showSuccess(BuildContext context, String message, {String title = 'Success', Color? backgroundColor}) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: backgroundColor ?? Colors.green.shade600,
    );
  }

  static void showInfo(BuildContext context, String message, {String title = 'Info', Color? backgroundColor}) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: backgroundColor ?? Colors.blueGrey,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    required Color backgroundColor,
  }) {
    final snackBar = SnackBar(
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
    );

    ScaffoldMessenger.of(context).clearSnackBars(); // clear any existing
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
