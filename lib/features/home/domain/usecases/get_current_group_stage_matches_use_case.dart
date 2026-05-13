import 'package:injectable/injectable.dart';

import '../../../../shared/models/match.dart';
import '../repositories/fixtures_repository.dart';

@injectable
class GetCurrentGroupStageMatchesUseCase {
  const GetCurrentGroupStageMatchesUseCase(this._repository);

  final FixturesRepository _repository;

  Future<List<Match>> call({bool forceRefresh = false}) =>
      _repository.getCurrentGroupStageMatches(forceRefresh: forceRefresh);
}
