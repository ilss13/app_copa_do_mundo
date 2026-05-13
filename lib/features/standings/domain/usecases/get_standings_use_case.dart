import 'package:injectable/injectable.dart';

import '../../../../shared/models/team_standing.dart';
import '../repositories/standings_repository.dart';

@injectable
class GetStandingsUseCase {
  const GetStandingsUseCase(this._repository);

  final StandingsRepository _repository;

  Future<Map<String, List<TeamStanding>>> call({bool forceRefresh = false}) =>
      _repository.getStandings(forceRefresh: forceRefresh);
}
