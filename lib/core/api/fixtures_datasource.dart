import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../shared/models/fixture_dto.dart';
import '../config/app_config.dart';
import 'api_client.dart';

@lazySingleton
class FixturesDataSource {
  const FixturesDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> fetchTodayRaw() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await _client.get('/fixtures', queryParameters: {
      'date': today,
      'league': AppConfig.worldCupLeagueId,
      'season': AppConfig.worldCupSeason,
    });
    return (response['response'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchAllRaw() async {
    final response = await _client.get('/fixtures', queryParameters: {
      'league': AppConfig.worldCupLeagueId,
      'season': AppConfig.worldCupSeason,
    });
    return (response['response'] as List).cast<Map<String, dynamic>>();
  }

  List<FixtureDto> parseDtos(List<Map<String, dynamic>> raw) =>
      raw.map(FixtureDto.fromJson).toList();
}
