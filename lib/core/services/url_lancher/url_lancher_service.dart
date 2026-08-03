import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  UrlLauncherService._();

  static Future<void> launch(
    String urlString, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final Uri url = Uri.parse(urlString.trim());

    try {
      // First attempt using the specified mode
      bool launched = false;

      if (await canLaunchUrl(url)) {
        launched = await launchUrl(url, mode: mode);
      }

      // Fallback: If canLaunchUrl failed or launch failed, try direct launch with platform default
      if (!launched) {
        launched = await launchUrl(url, mode: LaunchMode.platformDefault);
      }

      if (!launched) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      // In case of error, try one last time with platform default if not already tried
      try {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (_) {
        rethrow;
      }
    }
  }

  static Future<void> launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
    await launch(emailLaunchUri.toString());
  }

  static Future<void> launchPhone(String phoneNumber) async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launch(phoneLaunchUri.toString());
  }
}
