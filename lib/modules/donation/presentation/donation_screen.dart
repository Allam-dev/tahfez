import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageText = context.tr(LocaleKeys.prayForMeMessage);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr(LocaleKeys.donation))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Icon Container
                Container(
                  width: 90.r,
                  height: 90.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2.r,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 44.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),

                SizedBox(height: 32.h),

                // Card Container holding the Dua Phrase
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 36.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 36.sp,
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        messageText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Icon(
                        Icons.format_quote_rounded,
                        size: 36.sp,
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
