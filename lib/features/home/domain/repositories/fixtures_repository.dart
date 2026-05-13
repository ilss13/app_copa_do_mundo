import '../../../../shared/models/match.dart';

abstract class FixturesRepository {
  Future<List<Match>> getTodayMatches({bool forceRefresh = false});
  Future<List<Match>> getCurrentGroupStageMatches({bool forceRefresh = false});
}
