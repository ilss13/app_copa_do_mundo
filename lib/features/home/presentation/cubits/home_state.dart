import 'package:equatable/equatable.dart';

import '../../../../shared/models/match.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.matches);

  final List<Match> matches;

  List<Match> get liveMatches => matches.where((m) => m.isLive).toList();
  List<Match> get upcomingMatches => matches.where((m) => m.isUpcoming).toList();
  List<Match> get finishedMatches => matches.where((m) => m.isFinished).toList();
  String get currentRound => matches.isNotEmpty ? matches.first.round : '';

  @override
  List<Object?> get props => [matches];
}

class HomeEmpty extends HomeState {
  const HomeEmpty();
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
