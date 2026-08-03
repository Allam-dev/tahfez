import 'package:flutter/material.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';

class SuccessSnackBar extends SnackBar {
  SuccessSnackBar({
    super.key,
    required String message,
    super.duration = const Duration(seconds: 4),
  }) : super(
         content: Row(
           children: [
             const Icon(Icons.check_circle, color: Colors.white),
             const SizedBox(width: 12),
             Expanded(
               child: Text(
                 message,
                 style: const TextStyle(color: Colors.white),
               ),
             ),
           ],
         ),
         backgroundColor: AppColors.success,
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       );
}
