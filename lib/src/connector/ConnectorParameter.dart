
const String presetCharsetName = 'utf-8';
const String presetUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36";

class ConnectorParameter{
  String url;
  Map<String , String > data;
  String charsetName = presetCharsetName;
  String userAgent = presetUserAgent;
  ConnectorParameter(this.url);
}