import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';

class DynamicLinkProvider {
  Future<String> createLink(String refCode) async {
    final String url = "https://com.khe.dev?ref=$refCode";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        androidParameters: const AndroidParameters(
            packageName: "com.khe.dev", minimumVersion: 0),
        iosParameters:
            const IOSParameters(bundleId: "com.khe.dev", minimumVersion: "0"),
        link: Uri.parse(url),
        uriPrefix: "https://khe.page.link");

    final FirebaseDynamicLinks link = await FirebaseDynamicLinks.instance;
    final refLink = await link.buildShortLink(parameters);
    return refLink.shortUrl.toString();
  }

  void initDynamicLink() async {
    final instanceLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (instanceLink != null) {
      final Uri refLink = instanceLink.link;

      Share.share("This is the Link ${refLink.data}");
    }
  }
}
