//
//  connector_parameter.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

const String presetCharsetName = 'utf-8';
const String presetComputerUserAgent =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36";
const String presetUserAgent =
    "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1";

class ConnectorParameter {
  String url;
  dynamic data;
  String charsetName = presetCharsetName; //設定編碼預設utf-8 可以設定big5
  String userAgent = presetComputerUserAgent;
  String referer;

  ConnectorParameter(this.url);
}
