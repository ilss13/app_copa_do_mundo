import 'package:injectable/injectable.dart';

import '../../../../core/api/fixtures_datasource.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/models/fixture_dto.dart';
import '../../../../shared/models/match.dart';
import '../../domain/repositories/fixtures_repository.dart';

@LazySingleton(as: FixturesRepository)
class FixturesRepositoryImpl implements FixturesRepository {
  const FixturesRepositoryImpl(this._dataSource, this._cache);

  final FixturesDataSource _dataSource;
  final CacheManager _cache;

  static const _cacheKeyToday = 'today_matches';
  // Shared with GroupMatchesRepositoryImpl to reuse the same cached payload.
  static const _cacheKeyAll = 'all_fixtures';

  @override
  Future<List<Match>> getTodayMatches({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.get(_cacheKeyToday);
      if (cached != null) {
        return (cached as List)
            .cast<Map<String, dynamic>>()
            .map(FixtureDto.fromJson)
            .map((d) => d.toEntity())
            .toList();
      }
    }

    final raw = await _dataSource.fetchTodayRaw();
    await _cache.set(_cacheKeyToday, raw, ttlSeconds: AppConfig.cacheTtlTodayMatches);
    return _dataSource.parseDtos(raw).map((d) => d.toEntity()).toList();
  }

  @override
  Future<List<Match>> getCurrentGroupStageMatches({bool forceRefresh = false}) async {
    final all = await _fetchAll(forceRefresh: forceRefresh);
    final groupStage = all.where((m) => m.round.startsWith('Group Stage')).toList();
    if (groupStage.isEmpty) return [];
    final round = _currentRound(groupStage);
    return groupStage.where((m) => m.round == round).toList();
  }

  Future<List<Match>> _fetchAll({required bool forceRefresh}) async {
    if (!forceRefresh) {
      final cached = _cache.get(_cacheKeyAll);
      if (cached != null) {
        return (cached as List)
            .cast<Map<String, dynamic>>()
            .map(FixtureDto.fromJson)
            .map((d) => d.toEntity())
            .toList();
      }
    }
    final raw = await _dataSource.fetchAllRaw();
    await _cache.set(_cacheKeyAll, raw, ttlSeconds: AppConfig.cacheTtlAllMatches);
    return _dataSource.parseDtos(raw).map((d) => d.toEntity()).toList();
  }

  String _currentRound(List<Match> groupStageMatches) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Round with a live match
    for (final m in groupStageMatches) {
      if (m.isLive) return m.round;
    }

    // 2. Round with matches today
    for (final m in groupStageMatches) {
      final day = DateTime(m.date.year, m.date.month, m.date.day);
      if (day == today) return m.round;
    }

    // 3. Earliest upcoming round
    final upcoming = groupStageMatches.where((m) => m.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (upcoming.isNotEmpty) return upcoming.first.round;

    // 4. Most recently completed round
    final past = groupStageMatches.where((m) => m.date.isBefore(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return past.isNotEmpty ? past.first.round : groupStageMatches.first.round;
  }
}
