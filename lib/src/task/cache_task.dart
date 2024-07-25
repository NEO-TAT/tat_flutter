import 'dart:developer';
import 'dialog_task.dart';

class CacheTask<T> extends DialogTask<T> {
  CacheTask(String name) : super(name);

  final Map<String, T> _cache = {};

  void checkCache() {
    log("[TAT] cache_task.dart: checking cache for key: $name");
    fallback = _cache.containsKey(name);
    log("[TAT] cache_task.dart: cache for key $name exist: $fallback");
  }

  T? readCache() {
    return _cache[name];
  }

  void writeCache(String key, value) {
    _cache[name] = value;
  }
}
