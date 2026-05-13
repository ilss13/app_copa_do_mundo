import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_exception.dart';
import '../../domain/usecases/get_current_group_stage_matches_use_case.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getCurrentGroupStageMatches) : super(const HomeInitial());

  final GetCurrentGroupStageMatchesUseCase _getCurrentGroupStageMatches;

  Future<void> load({bool forceRefresh = false}) async {
    emit(const HomeLoading());
    try {
      final matches = await _getCurrentGroupStageMatches(forceRefresh: forceRefresh);
      emit(matches.isEmpty ? const HomeEmpty() : HomeLoaded(matches));
    } on ApiException catch (e) {
      emit(HomeError(e.message));
    } catch (_) {
      emit(const HomeError('Erro inesperado. Tente novamente.'));
    }
  }

  Future<void> refresh() => load(forceRefresh: true);
}
