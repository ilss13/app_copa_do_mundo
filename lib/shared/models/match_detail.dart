import 'package:equatable/equatable.dart';

import 'match.dart';
import 'match_event.dart';
import 'match_statistic.dart';
import 'team_lineup.dart';

class MatchDetail extends Equatable {
  const MatchDetail({
    required this.match,
    required this.events,
    this.homeLineup,
    this.awayLineup,
    required this.statistics,
    required this.h2hMatches,
  });

  final Match match;
  final List<MatchEvent> events;
  final TeamLineup? homeLineup;
  final TeamLineup? awayLineup;
  final List<MatchStatistic> statistics;
  final List<Match> h2hMatches;

  List<MatchEvent> get homeEvents =>
      events.where((e) => e.teamId == match.homeTeam.id).toList();

  List<MatchEvent> get awayEvents =>
      events.where((e) => e.teamId == match.awayTeam.id).toList();

  MatchDetail copyWith({
    Match? match,
    List<MatchEvent>? events,
    TeamLineup? homeLineup,
    TeamLineup? awayLineup,
    List<MatchStatistic>? statistics,
    List<Match>? h2hMatches,
  }) {
    return MatchDetail(
      match: match ?? this.match,
      events: events ?? this.events,
      homeLineup: homeLineup ?? this.homeLineup,
      awayLineup: awayLineup ?? this.awayLineup,
      statistics: statistics ?? this.statistics,
      h2hMatches: h2hMatches ?? this.h2hMatches,
    );
  }

  @override
  List<Object?> get props => [match, events, homeLineup, awayLineup, statistics, h2hMatches];
}
