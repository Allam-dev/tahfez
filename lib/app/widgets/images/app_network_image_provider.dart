import 'package:cached_network_image/cached_network_image.dart';

class AppNetworkImageProvider extends CachedNetworkImageProvider {
  AppNetworkImageProvider(
    String url, {
    super.maxHeight,
    super.maxWidth,
    super.scale,
    super.errorListener,
    super.headers,
    super.cacheManager,
    super.cacheKey,
  }) : super(_validateUrl(url));

  static String _validateUrl(String url) {
    final bool isInvalidUrl =
        url.isEmpty || (Uri.tryParse(url)?.hasAbsolutePath != true);
    if (isInvalidUrl) {
      // Provide a safe dummy URL that fails gracefully via CachedNetworkImageProvider
      // without causing Uri.parse exceptions on empty or malformed strings.
      return 'http://0.0.0.0/invalid_image.png';
    }
    return url;
  }
}
