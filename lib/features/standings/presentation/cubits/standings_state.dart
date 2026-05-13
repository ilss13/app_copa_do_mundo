import 'package:equatable/equatable.dart';

import '../../../../shared/models/team_standing.dart';

sealed class StandingsState extends Equatable {
  const StandingsState();

  @override
  List<Object?> get props => [];
}

class StandingsInitial extends StandingsState {
  const StandingsInitial();
}

class StandingsLoading extends StandingsState {
  const StandingsLoading();
}

class StandingsLoaded extends StandingsState {
  const StandingsLoaded(this.grouped);

  final Map<String, List<TeamStanding>> grouped;

  List<String> get groups => grouped.keys.toList();

  @override
  List<Object?> get props => [grouped];
}

class StandingsError extends StandingsState {
  const StandingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
