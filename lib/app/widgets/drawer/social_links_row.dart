import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/app/widgets/drawer/models/social_link_model.dart';
import 'package:tahfez/core/constants/app_links.dart';
import 'package:tahfez/core/services/url_lancher/url_lancher_service.dart';

class SocialLinksRow extends StatelessWidget {
  const SocialLinksRow({super.key});

  static const List<SocialLinkModel> _socialLinks = [
    SocialLinkModel(
      icon: FontAwesomeIcons.github,
      url: AppLinks.githubRepo,
      tooltipKey: LocaleKeys.github,
    ),
    SocialLinkModel(
      icon: FontAwesomeIcons.linkedin,
      url: AppLinks.linkedin,
      tooltipKey: LocaleKeys.linkedin,
    ),
    SocialLinkModel(
      icon: FontAwesomeIcons.facebook,
      url: AppLinks.facebook,
      tooltipKey: LocaleKeys.facebook,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _socialLinks.map((link) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Tooltip(
            message: context.tr(link.tooltipKey),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () => UrlLauncherService.launch(link.url),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: FaIcon(
                    link.icon,
                    size: 20.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
