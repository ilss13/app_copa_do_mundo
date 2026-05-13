import 'package:equatable/equatable.dart';

import '../../../../shared/models/match_detail.dart';

sealed class MatchDetailState extends Equatable {
  const MatchDetailState();
}

class MatchDetailInitial extends MatchDetailState {
  const MatchDetailInitial();

  @override
  List<Object?> get props => [];
}

class MatchDetailLoading extends MatchDetailState {
  const MatchDetailLoading();

  @override
  List<Object?> get props => [];
}

class MatchDetailLoaded extends MatchDetailState {
  const MatchDetailLoaded(this.detail, {this.isPolling = false});

  final MatchDetail detail;
  final bool isPolling;

  MatchDetailLoaded copyWith({MatchDetail? detail, bool? isPolling}) {
    return MatchDetailLoaded(
      detail ?? this.detail,
      isPolling: isPolling ?? this.isPolling,
    );
  }

  @override
  List<Object?> get props => [detail, isPolling];
}

class MatchDetailError extends MatchDetailState {
  const MatchDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
