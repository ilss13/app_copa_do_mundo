import 'package:injectable/injectable.dart';

import '../../../../shared/models/match_detail.dart';
import '../repositories/match_detail_repository.dart';

@injectable
class GetMatchDetailUseCase {
  const GetMatchDetailUseCase(this._repository);

  final MatchDetailRepository _repository;

  Future<MatchDetail> call(int fixtureId) => _repository.getMatchDetail(fixtureId);

  Future<MatchDetail> refresh(int fixtureId) => _repository.refreshMatchDetail(fixtureId);
}
