library big5;

part 'table.dart';

// only non-sream version

const Big5Codec big5 = const Big5Codec();

class Big5Codec {
  const Big5Codec();

  String decode(List<int> src) {
    return Big5TransformDecode(src);
  }

  List<int> encode(String src) {
    return Big5TransformEncode(src);
  }
}

// big5 constants.
const int RUNE_ERROR = 0xFFFD;
const int RUNE_SELF = 0x80;

String Big5TransformDecode(List<int> src) {
  var r = 0;
  var size = 0;
  var nDst = '';

  var nSrc = 0;

  void write(input) => nDst += (new String.fromCharCode(input));

  for (var nSrc = 0; nSrc < src.length; nSrc += size) {
    var c0 = src[nSrc];
    if (c0 < 0x80) {
      r = c0;
      size = 1;
    } else if (0x81 <= c0 && c0 < 0xFF) {
      if (nSrc + 1 >= src.length) {
        r = RUNE_ERROR;
        size = 1;
        write(r);
        continue;
      }
      var c1 = src[nSrc + 1];
      r = 0xfffd;
      size = 2;

      var i = c0 * 16 * 16 + c1;
      var s = decode[i];
      if (s != null) {
        write(s);
        continue;
      }
    } else {
      r = RUNE_ERROR;
      size = 1;
    }
    write(r);
    continue;
  }
  return nDst;
}

List<int> Big5TransformEncode(String src) {
  var runes = Runes(src).toList();

  var r = 0;
  var size = 0;
  List<int> dst = [];

  void write2(int r) {
    dst.add(r >> 8);
    dst.add(r % 256);
  }

  for (var nSrc = 0; nSrc < runes.length; nSrc += size) {
    r = runes[nSrc];

    // Decode a 1-byte rune.
    if (r < RUNE_SELF) {
      size = 1;
      dst.add(r);
      continue;
    } else {
      // Decode a multi-byte rune.
      // TODO handle some error
      size = 1;
    }

    if (r >= RUNE_SELF) {
      if (encode0Low <= r && r < encode0High) {
        r = encode0[r - encode0Low];
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode1Low <= r && r < encode1High) {
        r = encode1[r - encode1Low];
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode2Low <= r && r < encode2High) {
        r = encode2[r - encode2Low];
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode3Low <= r && r < encode3High) {
        r = encode3[r - encode3Low];
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode4Low <= r && r < encode4High) {
        r = encode4[r - encode4Low];
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode5Low <= r && r < encode5High) {
        r = encode5[r - encode5Low];
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode6Low <= r && r < encode6High) {
        r = encode6[r - encode6Low];
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode7Low <= r && r < encode7High) {
        r = encode7[r - encode7Low];
        if (r != 0) {
          write2(r);
          continue;
        }
      }
      // TODO handle err
      break;
    }
  }
  return dst;
}
