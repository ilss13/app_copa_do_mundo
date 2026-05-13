import 'package:equatable/equatable.dart';

import 'team.dart';

class TeamStanding extends Equatable {
  const TeamStanding({
    required this.rank,
    required this.team,
    required this.group,
    required this.points,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  final int rank;
  final Team team;
  final String group;
  final int points;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  int get goalDiff => goalsFor - goalsAgainst;

  @override
  List<Object?> get props => [rank, team, group, points, played];
}
