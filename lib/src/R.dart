import 'package:flutter/cupertino.dart';

import '../generated/l10n.dart';

class R {
  static BuildContext _context;
  static S current = S.of(_context);

  static set(BuildContext setContext) {
    _context = setContext;
  }

  static load(Locale locale) {
    S.delegate.load(locale);
  }
}
