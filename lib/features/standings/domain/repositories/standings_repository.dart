import '../../../../shared/models/team_standing.dart';

abstract class StandingsRepository {
  Future<Map<String, List<TeamStanding>>> getStandings({bool forceRefresh = false});
}
