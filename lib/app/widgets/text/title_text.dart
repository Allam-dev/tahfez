import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';

class TitleText extends StatelessWidget {
  final int number;

  final String text;
  const TitleText({super.key, required this.text, required this.number});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$number. $text',
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.green600,
      ),
    );
  }
}
