import '../../../../shared/models/match_detail.dart';

abstract interface class MatchDetailRepository {
  Future<MatchDetail> getMatchDetail(int fixtureId);
  Future<MatchDetail> refreshMatchDetail(int fixtureId);
}
