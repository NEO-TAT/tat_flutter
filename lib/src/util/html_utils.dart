// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:html_unescape/html_unescape.dart';

class HtmlUtils {
  static String clean(String html) {
    String result;
    var unescape = HtmlUnescape();
    result = unescape.convert(html);
    return result;
  }

  static String addLink(String html) {
    RegExp exp = RegExp(r'\"?(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\"?');
    List<RegExpMatch> matchList = exp.allMatches(html).toList();
    for (RegExpMatch match in matchList) {
      final url = match.group(0);
      if (!url.contains("\"")) {
        html = html.replaceAll(url, '<a href="$url" target="_blank">$url</a>');
      }
    }
    return html;
  }
}
