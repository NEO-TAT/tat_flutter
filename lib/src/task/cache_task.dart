import 'dart:developer';
import 'dialog_task.dart';

class CacheTask<T> extends DialogTask<T> {
  CacheTask(String name) : super(name);

  final Map<String, T> _cache = {};
  bool isCached = false;

  void checkCache() {
    log("[TAT] cache_task.dart: checking cache for key: $name");
    isCached = _cache.containsKey(name);
    log("[TAT] cache_task.dart: cache for key $name exist: $isCached");
  }

  void loadCache() {
    result = _cache[name];
    onErrorButCached();
  }

  void writeCache(String key, value) {
    _cache[name] = value;
  }
}
