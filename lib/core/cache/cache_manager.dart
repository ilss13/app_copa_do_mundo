import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import 'cache_entry.dart';

class CacheManager {
  static const _boxName = 'api_cache';
  late Box<CacheEntry> _box;

  Future<void> init() async {
    Hive.registerAdapter(CacheEntryAdapter());
    _box = await Hive.openBox<CacheEntry>(_boxName);
  }

  Future<void> set(String key, dynamic data, {required int ttlSeconds}) async {
    final entry = CacheEntry(
      data: jsonEncode(data),
      expiresAt: DateTime.now().add(Duration(seconds: ttlSeconds)),
    );
    await _box.put(key, entry);
  }

  dynamic get(String key) {
    final entry = _box.get(key);
    if (entry == null || entry.isExpired) {
      _box.delete(key);
      return null;
    }
    return jsonDecode(entry.data);
  }

  bool has(String key) {
    final entry = _box.get(key);
    return entry != null && !entry.isExpired;
  }

  Future<void> invalidate(String key) async => _box.delete(key);

  Future<void> invalidateAll() async => _box.clear();

  Future<void> invalidatePrefix(String prefix) async {
    final keysToDelete = _box.keys.where((k) => k.toString().startsWith(prefix)).toList();
    await _box.deleteAll(keysToDelete);
  }
}
