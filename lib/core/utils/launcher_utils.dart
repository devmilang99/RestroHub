import 'package:url_launcher/url_launcher.dart';

class LauncherUtils {
  /// Launches the phone dialer with the given [phone].
  static Future<void> launchPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  /// Launches a web URL.
  static Future<void> launchWeb(String webUrl) async {
    final url = Uri.parse(webUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }
}
