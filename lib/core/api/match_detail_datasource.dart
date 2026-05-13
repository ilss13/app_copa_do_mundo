import 'package:injectable/injectable.dart';

import '../../shared/models/fixture_dto.dart';
import '../../shared/models/match_event.dart';
import '../../shared/models/match_statistic.dart';
import '../../shared/models/team_lineup.dart';
import '../config/app_config.dart';
import 'api_client.dart';

@lazySingleton
class MatchDetailDataSource {
  const MatchDetailDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchFixtureRaw(int fixtureId) async {
    final response = await _client.get('/fixtures', queryParameters: {
      'id': fixtureId,
    });
    final list = (response['response'] as List).cast<Map<String, dynamic>>();
    return list.isNotEmpty ? list.first : {};
  }

  Future<List<Map<String, dynamic>>> fetchLineupsRaw(int fixtureId) async {
    final response = await _client.get('/fixtures/lineups', queryParameters: {
      'fixture': fixtureId,
    });
    return (response['response'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchEventsRaw(int fixtureId) async {
    final response = await _client.get('/fixtures/events', queryParameters: {
      'fixture': fixtureId,
    });
    return (response['response'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchStatisticsRaw(int fixtureId) async {
    final response = await _client.get('/fixtures/statistics', queryParameters: {
      'fixture': fixtureId,
    });
    return (response['response'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchH2HRaw(int homeTeamId, int awayTeamId) async {
    final response = await _client.get('/fixtures/headtohead', queryParameters: {
      'h2h': '$homeTeamId-$awayTeamId',
      'league': AppConfig.worldCupLeagueId,
      'season': AppConfig.worldCupSeason,
      'last': 10,
    });
    return (response['response'] as List).cast<Map<String, dynamic>>();
  }

  FixtureDto parseFixture(Map<String, dynamic> raw) => FixtureDto.fromJson(raw);

  List<TeamLineup> parseLineups(List<Map<String, dynamic>> raw) =>
      raw.map(TeamLineup.fromJson).toList();

  List<MatchEvent> parseEvents(List<Map<String, dynamic>> raw) =>
      raw.map(MatchEvent.fromJson).toList();

  List<MatchStatistic> parseStatistics(List<Map<String, dynamic>> raw) {
    if (raw.length < 2) return [];
    final homeStats = raw[0]['statistics'] as List<dynamic>? ?? [];
    final awayStats = raw[1]['statistics'] as List<dynamic>? ?? [];
    return MatchStatistic.fromTeamJsonPair(homeStats, awayStats);
  }

  List<FixtureDto> parseH2H(List<Map<String, dynamic>> raw) =>
      raw.map(FixtureDto.fromJson).toList();
}
