import 'package:flutter/material.dart';

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    super.key,
    String message = 'error',
    super.duration = const Duration(seconds: 4),
  }) : super(
         content: Row(
           children: [
             const Icon(Icons.error_outline, color: Colors.white),
             const SizedBox(width: 12),
             Expanded(
               child: Text(
                 message,
                 style: const TextStyle(color: Colors.white),
               ),
             ),
           ],
         ),
         backgroundColor: Colors.red.shade800,
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       );
}
