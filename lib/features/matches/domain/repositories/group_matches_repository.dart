import '../../../../shared/models/match.dart';

abstract class GroupMatchesRepository {
  /// Retorna jogos agrupados por grupo ("Group A", "Group B", ...).
  /// Fases eliminatórias usam o nome da rodada como chave.
  Future<Map<String, List<Match>>> getGroupedMatches({bool forceRefresh = false});
}
