import 'package:equatable/equatable.dart';

import 'team.dart';
import 'match_status.dart';

class Match extends Equatable {
  const Match({
    required this.id,
    required this.date,
    required this.round,
    required this.homeTeam,
    required this.awayTeam,
    required this.status,
    this.homeGoals,
    this.awayGoals,
    this.elapsed,
    this.venue,
  });

  final int id;
  final DateTime date;
  final String round;
  final Team homeTeam;
  final Team awayTeam;
  final MatchStatus status;
  final int? homeGoals;
  final int? awayGoals;
  final int? elapsed;
  final String? venue;

  bool get isLive => status.isLive;
  bool get isFinished => status.isFinished;
  bool get isUpcoming => status.isUpcoming;

  @override
  List<Object?> get props => [id, homeTeam, awayTeam, status, homeGoals, awayGoals, elapsed];
}
