// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
class JsonInit {
  static String stringInit(String value) {
    return value ?? "";
  }

  static List<T> listInit<T>(List<T> value) {
    return value ?? [] as List<T>;
  }
}
