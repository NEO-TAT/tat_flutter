class CacheStorage {
  CacheStorage._();

  factory CacheStorage() => _instance;
  static final _instance = CacheStorage._();

  static CacheStorage get instance => _instance;

  final Map<String, dynamic> cache = {};
}
