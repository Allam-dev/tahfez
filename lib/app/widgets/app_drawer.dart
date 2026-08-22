import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/extensions/context/navigation.dart';
import 'package:tahfez/core/extensions/context/theme.dart';
import 'package:tahfez/core/extensions/locale/language_name.dart';
import 'package:tahfez/modules/donation/presentation/donation_screen.dart';
import 'package:tahfez/modules/reader/presentation/readers/readers_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 36.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: 12.h),
                Text(
                  'تحفيظ',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Downloads
          ListTile(
            leading: Icon(
              Icons.download_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              context.tr(LocaleKeys.downloads),
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              Navigator.pop(context); // close drawer
              context.push(const ReadersScreen());
            },
          ),

          // Donation
          ListTile(
            leading: Icon(
              Icons.favorite_rounded,
              color: theme.colorScheme.secondary,
            ),
            title: Text(
              context.tr(LocaleKeys.donation),
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              Navigator.pop(context); // close drawer
              context.push(const DonationScreen());
            },
          ),
          // change theme
          SwitchListTile.adaptive(
            value: context.isDarkMode,
            onChanged: (value) => context.switchTheme(value),
            title: Text(context.tr(LocaleKeys.darkMode)),
          ),

          10.verticalSpace,
          // change language
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownMenu(
              dropdownMenuEntries: context.supportedLocales
                  .map((e) => DropdownMenuEntry(value: e, label: e.name))
                  .toList(),
              initialSelection: context.locale,
              expandedInsets: EdgeInsets.zero,
              onSelected: (value) {
                if (value != null) {
                  context.setLocale(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
