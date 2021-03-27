import 'package:html_unescape/html_unescape.dart';

class HtmlUtils {
  /*
  「		雙引號			&quot;		×	乘號				&times;		←	向左箭頭				&larr;
  &		AND符號			&amp;		÷	除號				&divide;		↑	向上箭頭			&uarr;
  <		小於符號		&lt;		±	正負符號			&plusmn;		→	向右箭頭			&rarr;
  >		大於符號		&gt;			function符號		&fnof;		↓	向下箭頭				&darr;
      空格			&nbsp;		√	根號				&radic;			雙向箭頭				&harr;
  		倒問號			&iquest;	∞	無限大符號			&infin;		⇐	雙線向左箭頭			&lArr;
  «		雙左箭頭		&laquo;		∠	角度符號			&ang;		⇑	雙線向上箭頭			&uArr;
  »		雙右箭頭		&raquo;		∫	微積分符號			&int;		⇒	雙線向右箭頭			&rArr;
  『		左單引號		&lsquo;		°	度數符號			&deg;		⇓	雙線向下箭頭			&dArr;
  』		右單引號		&rsquo;		≠	不等於符號			&ne;			雙線雙向箭頭			&hArr;
  「		左雙引號		&ldquo;		≡	相等符號			&equiv;			黑桃符號				&spades;
  」		右雙引號		&rdquo;		≦	小於等於符號		&le;			梅花符號				&clubs;
  		段落符號		&para;		≧	大於等於符號		&ge;			紅心符號				&hearts;
  §		章節符號		&sect;		⊥	垂直符號			&perp;			方塊符號				&diams;
  ©		版權所有符號	&copy;			二分之一符號		&frac12;	α	Alpha符號				&alpha;
  		註冊商標符號	&reg;			四分之一符號		&frac14;	β	Bata符號				&beta;
  		商標符號		&trade;			四分之三符號		&frac34;	γ	Gamma符號				&gamma;
  €		歐元符號		&euro;			百分符號			&permil;	Δ	Delta符號				&Delta;
  ¢		美分符號		&cent;		∴	所以符號			&there4;	θ	Theta符號				&theta;
  £		英鎊符號		&pound;		π	圓周率符號			&pi;		λ	Lambda符號				&lambda;
  ¥		日圓符號		&yen;		¹	註解1符號			&sup1;		Σ	Sigma符號				&Sigma;
  …		…				&hellip;	²	註解2符號、平方		&sup2;		τ	Tau符號					&tau;
  ⊕		 				&oplus;		³	註解3符號、立方		&sup3;		ω	Omega符號				&omega;
  ∇		倒三角型符號	&nabla;		↵	ENTER符號			&crarr;		Ω	Omega符號、歐姆符號		&Omega;
   */
  static String clean(String html) {
    String result;
    var unescape = new HtmlUnescape();
    result = unescape.convert(html);
    return result;
  }

  static String addLink(String html) {
    RegExp exp = RegExp(
        r'\"?(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\"?');
    List<RegExpMatch> matchList = exp.allMatches(html).toList();
    for (RegExpMatch match in matchList) {
      String url = match.group(0);
      print(url);
      if (!url.contains("\"")) {
        html = html.replaceAll(
            url, r'<a href="' + url + '" target="_blank">' + url + '</a>');
      }
    }
    return html;
  }
}
