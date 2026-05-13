import 'package:injectable/injectable.dart';

import '../../../../core/api/standings_datasource.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/models/standing_dto.dart';
import '../../../../shared/models/team_standing.dart';
import '../../domain/repositories/standings_repository.dart';

@LazySingleton(as: StandingsRepository)
class StandingsRepositoryImpl implements StandingsRepository {
  const StandingsRepositoryImpl(this._dataSource, this._cache);

  final StandingsDataSource _dataSource;
  final CacheManager _cache;

  static const _cacheKey = 'standings';

  @override
  Future<Map<String, List<TeamStanding>>> getStandings({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.get(_cacheKey);
      if (cached != null) {
        return _parseFromCache(cached as Map<String, dynamic>);
      }
    }

    final raw = await _dataSource.fetchRaw();
    final grouped = _dataSource.parseGrouped(raw);

    // Serializa para cache: Map<groupName, List<Map>>
    final cacheData = grouped.map(
      (k, v) => MapEntry(k, v.map(_dtoToRaw).toList()),
    );
    await _cache.set(_cacheKey, cacheData, ttlSeconds: AppConfig.cacheTtlStandings);

    return grouped.map((k, v) => MapEntry(k, v.map((d) => d.toEntity()).toList()));
  }

  Map<String, List<TeamStanding>> _parseFromCache(Map<String, dynamic> cached) {
    return cached.map((group, list) {
      final entries = (list as List)
          .cast<Map<String, dynamic>>()
          .map(StandingEntryDto.fromJson)
          .map((d) => d.toEntity())
          .toList();
      return MapEntry(group, entries);
    });
  }

  Map<String, dynamic> _dtoToRaw(StandingEntryDto d) => {
        'rank': d.rank,
        'team': {'id': d.teamId, 'name': d.teamName, 'logo': d.teamLogo},
        'group': d.group,
        'points': d.points,
        'all': {
          'played': d.played,
          'win': d.wins,
          'draw': d.draws,
          'lose': d.losses,
          'goals': {'for': d.goalsFor, 'against': d.goalsAgainst},
        },
      };
}
