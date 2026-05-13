import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/usecases/get_match_detail_use_case.dart';
import 'match_detail_state.dart';

@injectable
class MatchDetailCubit extends Cubit<MatchDetailState> {
  MatchDetailCubit(this._useCase, this._analytics) : super(const MatchDetailInitial());

  final GetMatchDetailUseCase _useCase;
  final AnalyticsService _analytics;
  Timer? _pollingTimer;
  int? _fixtureId;

  Future<void> load(int fixtureId) async {
    _fixtureId = fixtureId;
    emit(const MatchDetailLoading());
    try {
      final detail = await _useCase(fixtureId);
      emit(MatchDetailLoaded(detail));
      unawaited(_analytics.logMatchViewed(fixtureId));
      if (detail.match.isLive) _startPolling();
    } catch (e) {
      emit(MatchDetailError(e.toString()));
    }
  }

  Future<void> refresh() async {
    final id = _fixtureId;
    if (id == null) return;
    try {
      final detail = await _useCase.refresh(id);
      final wasLive = detail.match.isLive;
      emit(MatchDetailLoaded(detail));
      if (wasLive) {
        _startPolling();
      } else {
        _stopPolling();
      }
    } catch (_) {
      // keep current state on silent refresh failure
    }
  }

  void logH2HBlocked() {
    final id = _fixtureId;
    if (id != null) unawaited(_analytics.logH2HBlocked(id));
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: AppConfig.pollingLiveMatch),
      (_) => _poll(),
    );
  }

  Future<void> _poll() async {
    final id = _fixtureId;
    if (id == null || isClosed) return;
    try {
      final detail = await _useCase.refresh(id);
      if (!isClosed) {
        emit(MatchDetailLoaded(detail, isPolling: true));
        if (!detail.match.isLive) _stopPolling();
      }
    } catch (_) {
      // silent — keep last known state
    }
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
