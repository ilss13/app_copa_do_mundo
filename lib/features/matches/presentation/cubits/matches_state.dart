import 'package:equatable/equatable.dart';

import '../../../../shared/models/match.dart';

sealed class MatchesState extends Equatable {
  const MatchesState();

  @override
  List<Object?> get props => [];
}

class MatchesInitial extends MatchesState {
  const MatchesInitial();
}

class MatchesLoading extends MatchesState {
  const MatchesLoading();
}

class MatchesLoaded extends MatchesState {
  const MatchesLoaded(this.grouped);

  // Chave: "Group A", "Group B", etc.
  final Map<String, List<Match>> grouped;

  List<String> get groups => grouped.keys.toList();

  @override
  List<Object?> get props => [grouped];
}

class MatchesError extends MatchesState {
  const MatchesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
