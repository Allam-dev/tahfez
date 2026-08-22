import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLinkModel {
  final FaIconData icon;
  final String url;
  final String tooltipKey;

  const SocialLinkModel({
    required this.icon,
    required this.url,
    required this.tooltipKey,
  });
}
