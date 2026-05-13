import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_exception.dart';
import '../../domain/usecases/get_standings_use_case.dart';
import 'standings_state.dart';

@injectable
class StandingsCubit extends Cubit<StandingsState> {
  StandingsCubit(this._getStandings) : super(const StandingsInitial());

  final GetStandingsUseCase _getStandings;

  Future<void> load({bool forceRefresh = false}) async {
    emit(const StandingsLoading());
    try {
      final grouped = await _getStandings(forceRefresh: forceRefresh);
      emit(StandingsLoaded(grouped));
    } on ApiException catch (e) {
      emit(StandingsError(e.message));
    } catch (_) {
      emit(const StandingsError('Erro inesperado. Tente novamente.'));
    }
  }

  Future<void> refresh() => load(forceRefresh: true);
}
