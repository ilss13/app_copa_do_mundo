import 'package:injectable/injectable.dart';

import '../../../../core/api/match_detail_datasource.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/models/match_detail.dart';
import '../../domain/repositories/match_detail_repository.dart';

@LazySingleton(as: MatchDetailRepository)
class MatchDetailRepositoryImpl implements MatchDetailRepository {
  const MatchDetailRepositoryImpl(this._ds, this._cache);

  final MatchDetailDataSource _ds;
  final CacheManager _cache;

  static String _fixtureKey(int id) => 'fixture_$id';
  static String _eventsKey(int id) => 'events_$id';
  static String _lineupsKey(int id) => 'lineups_$id';
  static String _statsKey(int id) => 'stats_$id';
  static String _h2hKey(int homeId, int awayId) => 'h2h_${homeId}_$awayId';

  @override
  Future<MatchDetail> getMatchDetail(int fixtureId) => _load(fixtureId, forceRefresh: false);

  @override
  Future<MatchDetail> refreshMatchDetail(int fixtureId) => _load(fixtureId, forceRefresh: true);

  Future<MatchDetail> _load(int fixtureId, {required bool forceRefresh}) async {
    final fKey = _fixtureKey(fixtureId);

    // Fixture — always fresh for live matches; cached otherwise
    Map<String, dynamic> fixtureRaw;
    if (!forceRefresh && _cache.has(fKey)) {
      fixtureRaw = ((_cache.get(fKey)) as Map).cast<String, dynamic>();
    } else {
      fixtureRaw = await _ds.fetchFixtureRaw(fixtureId);
      await _cache.set(fKey, fixtureRaw, ttlSeconds: AppConfig.cacheTtlTodayMatches);
    }

    final fixture = _ds.parseFixture(fixtureRaw);
    final match = fixture.toEntity();
    final isLive = match.isLive;

    // Events
    final eKey = _eventsKey(fixtureId);
    List<Map<String, dynamic>> eventsRaw;
    if (!forceRefresh && !isLive && _cache.has(eKey)) {
      eventsRaw = ((_cache.get(eKey)) as List).cast<Map<String, dynamic>>();
    } else {
      eventsRaw = await _ds.fetchEventsRaw(fixtureId);
      final ttl = isLive ? AppConfig.cacheTtlTodayMatches : AppConfig.cacheTtlStatisticsFinished;
      await _cache.set(eKey, eventsRaw, ttlSeconds: ttl);
    }

    // Lineups
    final lKey = _lineupsKey(fixtureId);
    List<Map<String, dynamic>> lineupsRaw;
    if (!forceRefresh && _cache.has(lKey)) {
      lineupsRaw = ((_cache.get(lKey)) as List).cast<Map<String, dynamic>>();
    } else {
      lineupsRaw = await _ds.fetchLineupsRaw(fixtureId);
      if (lineupsRaw.isNotEmpty) {
        await _cache.set(lKey, lineupsRaw, ttlSeconds: AppConfig.cacheTtlLineups);
      }
    }

    // Statistics
    final sKey = _statsKey(fixtureId);
    List<Map<String, dynamic>> statsRaw;
    if (!forceRefresh && !isLive && _cache.has(sKey)) {
      statsRaw = ((_cache.get(sKey)) as List).cast<Map<String, dynamic>>();
    } else {
      statsRaw = await _ds.fetchStatisticsRaw(fixtureId);
      if (statsRaw.isNotEmpty) {
        final ttl = isLive ? AppConfig.cacheTtlTodayMatches : AppConfig.cacheTtlStatisticsFinished;
        await _cache.set(sKey, statsRaw, ttlSeconds: ttl);
      }
    }

    // H2H — long-lived cache
    final h2hKey = _h2hKey(match.homeTeam.id, match.awayTeam.id);
    List<Map<String, dynamic>> h2hRaw;
    if (!forceRefresh && _cache.has(h2hKey)) {
      h2hRaw = ((_cache.get(h2hKey)) as List).cast<Map<String, dynamic>>();
    } else {
      h2hRaw = await _ds.fetchH2HRaw(match.homeTeam.id, match.awayTeam.id);
      await _cache.set(h2hKey, h2hRaw, ttlSeconds: AppConfig.cacheTtlH2h);
    }

    final lineups = _ds.parseLineups(lineupsRaw);
    final homeLineup = lineups.where((l) => l.teamId == match.homeTeam.id).firstOrNull;
    final awayLineup = lineups.where((l) => l.teamId == match.awayTeam.id).firstOrNull;

    return MatchDetail(
      match: match,
      events: _ds.parseEvents(eventsRaw),
      homeLineup: homeLineup,
      awayLineup: awayLineup,
      statistics: _ds.parseStatistics(statsRaw),
      h2hMatches: _ds.parseH2H(h2hRaw).map((d) => d.toEntity()).toList(),
    );
  }
}
