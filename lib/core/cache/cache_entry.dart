import 'package:hive_flutter/hive_flutter.dart';

part 'cache_entry.g.dart';

@HiveType(typeId: 0)
class CacheEntry {
  CacheEntry({required this.data, required this.expiresAt});

  @HiveField(0)
  final String data;

  @HiveField(1)
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
