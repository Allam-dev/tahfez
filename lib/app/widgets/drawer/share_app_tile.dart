import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/constants/app_links.dart';

class ShareAppTile extends StatelessWidget {
  const ShareAppTile({super.key});
  void _onShare(BuildContext context) {
    final message = context.tr(
      LocaleKeys.shareAppMessage,
      args: [AppLinks.playStoreUrl],
    );
    SharePlus.instance.share(
      ShareParams(text: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.share_rounded, color: theme.colorScheme.primary),
      title: Text(
        context.tr(LocaleKeys.shareApp),
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.pop(context); // close drawer
        _onShare(context);
      },
    );
  }
}
