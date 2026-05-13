import 'package:injectable/injectable.dart';

import '../../../../shared/models/match.dart';
import '../repositories/group_matches_repository.dart';

@injectable
class GetGroupedMatchesUseCase {
  const GetGroupedMatchesUseCase(this._repository);

  final GroupMatchesRepository _repository;

  Future<Map<String, List<Match>>> call({bool forceRefresh = false}) =>
      _repository.getGroupedMatches(forceRefresh: forceRefresh);
}
