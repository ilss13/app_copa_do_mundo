import 'package:injectable/injectable.dart';

import '../../../../core/api/fixtures_datasource.dart';
import '../../../../core/api/standings_datasource.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/models/fixture_dto.dart';
import '../../../../shared/models/match.dart';
import '../../domain/repositories/group_matches_repository.dart';

@LazySingleton(as: GroupMatchesRepository)
class GroupMatchesRepositoryImpl implements GroupMatchesRepository {
  const GroupMatchesRepositoryImpl(
    this._fixturesDs,
    this._standingsDs,
    this._cache,
  );

  final FixturesDataSource _fixturesDs;
  final StandingsDataSource _standingsDs;
  final CacheManager _cache;

  static const _cacheKeyFixtures = 'all_fixtures';
  static const _cacheKeyTeamGroup = 'team_group_map';

  @override
  Future<Map<String, List<Match>>> getGroupedMatches({bool forceRefresh = false}) async {
    final teamGroupMap = await _getTeamGroupMap(forceRefresh: forceRefresh);
    final allMatches = await _getAllMatches(forceRefresh: forceRefresh);

    final grouped = <String, List<Match>>{};
    for (final match in allMatches) {
      final group = teamGroupMap[match.homeTeam.id] ?? match.round;
      grouped.putIfAbsent(group, () => []).add(match);
    }

    // Sort groups alphabetically, then knockout rounds at the end
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => _groupSortKey(a).compareTo(_groupSortKey(b)));

    return {for (final k in sortedKeys) k: grouped[k]!};
  }

  Future<Map<int, String>> _getTeamGroupMap({required bool forceRefresh}) async {
    if (!forceRefresh) {
      final cached = _cache.get(_cacheKeyTeamGroup);
      if (cached != null) {
        return (cached as Map<String, dynamic>)
            .map((k, v) => MapEntry(int.parse(k), v as String));
      }
    }
    final raw = await _standingsDs.fetchRaw();
    final grouped = _standingsDs.parseGrouped(raw);
    final map = _standingsDs.buildTeamGroupMap(grouped);
    await _cache.set(
      _cacheKeyTeamGroup,
      map.map((k, v) => MapEntry(k.toString(), v)),
      ttlSeconds: AppConfig.cacheTtlAllMatches,
    );
    return map;
  }

  Future<List<Match>> _getAllMatches({required bool forceRefresh}) async {
    if (!forceRefresh) {
      final cached = _cache.get(_cacheKeyFixtures);
      if (cached != null) {
        return (cached as List)
            .cast<Map<String, dynamic>>()
            .map(FixtureDto.fromJson)
            .map((d) => d.toEntity())
            .toList();
      }
    }
    final raw = await _fixturesDs.fetchAllRaw();
    await _cache.set(_cacheKeyFixtures, raw, ttlSeconds: AppConfig.cacheTtlAllMatches);
    return _fixturesDs.parseDtos(raw).map((d) => d.toEntity()).toList();
  }

  int _groupSortKey(String name) {
    if (name.startsWith('Group ')) return name.codeUnitAt(6);
    return 300; // knockout rounds after groups
  }
}
