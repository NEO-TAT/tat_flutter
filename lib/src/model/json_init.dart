class JsonInit {
  static int intInit(String value){
    return value.replaceAll(RegExp(r"\s"), "").isNotEmpty ? int.parse(value) : 0;
  }

  static double doubleInit(String value){
    return value.replaceAll(RegExp(r"\s"), "").isNotEmpty ? double.parse(value) : 0.00;
  }

  static String stringInit(String value) {
    return value ?? "";
  }

  static List<T> listInit<T>(List<T> value){
    return value ?? <T>[];
  }
}
