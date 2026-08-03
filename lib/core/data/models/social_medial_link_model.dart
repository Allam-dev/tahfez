import '../enums/social_media_platform.dart';

class SocialMediaLinkModel {
  SocialMediaPlatform platform;
  String url;

  SocialMediaLinkModel({required this.platform, required this.url});

  factory SocialMediaLinkModel.fromUrl(String url) {
    return SocialMediaLinkModel(platform: _getPlatformFromUrl(url), url: url);
  }

  Map<String, dynamic> toJson() {
    return {'platform': platform.name, 'url': url};
  }

  static SocialMediaPlatform _getPlatformFromUrl(String url) {
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.contains('facebook')) {
      return SocialMediaPlatform.facebook;
    } else if (lowerUrl.contains('linkedin')) {
      return SocialMediaPlatform.linkedin;
    } else if (lowerUrl.contains('instagram')) {
      return SocialMediaPlatform.instegram;
    } else if (lowerUrl.contains('x.com') || lowerUrl.contains('twitter')) {
      return SocialMediaPlatform.x;
    } else if (lowerUrl.contains('github')) {
      return SocialMediaPlatform.gitHub;
    } else if (lowerUrl.contains('youtube')) {
      return SocialMediaPlatform.youtube;
    } else {
      return SocialMediaPlatform.other;
    }
  }
}
