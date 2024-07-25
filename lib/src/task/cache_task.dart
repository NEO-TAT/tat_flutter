import 'dart:developer';
import 'dialog_task.dart';
import 'package:flutter_app/src/store/cache_storage.dart';

class CacheTask<T> extends DialogTask<T> {
  CacheTask(String name) : super(name);

  bool isCached = false;

  void checkCache() {
    log("[TAT] cache_task.dart: checking cache with  key: \"$name\"");
    isCached = CacheStorage.instance.cache.containsKey(name);
    log("[TAT] cache_task.dart: cache for key \"$name\" exist: $isCached");
  }

  void loadCache() {
    log("[TAT] cache_task.dart: loading cache with key \"$name\"");
    result = CacheStorage.instance.cache[name];
    onErrorButCached();
  }

  void writeCache() {
    log("[TAT] cache_task.dart: writing cache with key \"$name\"");
    CacheStorage.instance.cache[name] = result;
  }
}
