import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_exception.dart';
import '../../domain/usecases/get_grouped_matches_use_case.dart';
import 'matches_state.dart';

@injectable
class MatchesCubit extends Cubit<MatchesState> {
  MatchesCubit(this._getGroupedMatches) : super(const MatchesInitial());

  final GetGroupedMatchesUseCase _getGroupedMatches;

  Future<void> load({bool forceRefresh = false}) async {
    emit(const MatchesLoading());
    try {
      final grouped = await _getGroupedMatches(forceRefresh: forceRefresh);
      emit(MatchesLoaded(grouped));
    } on ApiException catch (e) {
      emit(MatchesError(e.message));
    } catch (_) {
      emit(const MatchesError('Erro inesperado. Tente novamente.'));
    }
  }

  Future<void> refresh() => load(forceRefresh: true);
}
