import 'package:injectable/injectable.dart';

import '../../shared/models/standing_dto.dart';
import '../config/app_config.dart';
import 'api_client.dart';

@lazySingleton
class StandingsDataSource {
  const StandingsDataSource(this._client);

  final ApiClient _client;

  Future<List<List<Map<String, dynamic>>>> fetchRaw() async {
    final response = await _client.get('/standings', queryParameters: {
      'league': AppConfig.worldCupLeagueId,
      'season': AppConfig.worldCupSeason,
    });
    final leagueData =
        ((response['response'] as List).first as Map<String, dynamic>)['league']
            as Map<String, dynamic>;
    final standings = leagueData['standings'] as List;
    return standings
        .map((g) => (g as List).cast<Map<String, dynamic>>())
        .toList();
  }

  Map<String, List<StandingEntryDto>> parseGrouped(
      List<List<Map<String, dynamic>>> raw) {
    final result = <String, List<StandingEntryDto>>{};
    for (final groupList in raw) {
      final entries = groupList.map(StandingEntryDto.fromJson).toList();
      if (entries.isNotEmpty) {
        result[entries.first.group] = entries;
      }
    }
    return result;
  }

  // Returns teamId → groupName map for cross-referencing with fixtures
  Map<int, String> buildTeamGroupMap(
      Map<String, List<StandingEntryDto>> grouped) {
    final map = <int, String>{};
    for (final entry in grouped.entries) {
      for (final s in entry.value) {
        map[s.teamId] = entry.key;
      }
    }
    return map;
  }
}
