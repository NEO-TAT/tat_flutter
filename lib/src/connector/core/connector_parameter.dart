//  北科課程助手

const presetCharsetName = 'utf-8';
const presetComputerUserAgent =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36";
const presetUserAgent =
    "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1";

class ConnectorParameter {
  String url;
  dynamic data;
  String charsetName = presetCharsetName; // setup encoding, default is UTF-8, can be set to BIG-5.
  String userAgent = presetComputerUserAgent;
  String? referer;

  ConnectorParameter(this.url, {this.data, this.referer});
}
