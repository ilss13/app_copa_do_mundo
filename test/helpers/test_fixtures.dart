import 'package:app_copa_do_mundo/shared/models/match.dart';
import 'package:app_copa_do_mundo/shared/models/match_detail.dart';
import 'package:app_copa_do_mundo/shared/models/match_status.dart';
import 'package:app_copa_do_mundo/shared/models/team.dart';
import 'package:app_copa_do_mundo/shared/models/team_standing.dart';

abstract final class TestFixtures {
  static const homeTeam = Team(id: 1, name: 'Brasil', logo: 'https://logo/br.png');
  static const awayTeam = Team(id: 2, name: 'Argentina', logo: 'https://logo/ar.png');

  static Match finishedMatch({int id = 1}) => Match(
        id: id,
        date: DateTime(2026, 6, 14, 18),
        round: 'Group Stage - 1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        status: MatchStatus.finished,
        homeGoals: 2,
        awayGoals: 1,
      );

  static Match liveMatch({int id = 2}) => Match(
        id: id,
        date: DateTime(2026, 6, 14, 18),
        round: 'Group Stage - 1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        status: MatchStatus.firstHalf,
        elapsed: 35,
      );

  static Match upcomingMatch({int id = 3}) => Match(
        id: id,
        date: DateTime(2026, 6, 15, 20),
        round: 'Group Stage - 2',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        status: MatchStatus.notStarted,
      );

  static MatchDetail finishedMatchDetail({int id = 1}) => MatchDetail(
        match: finishedMatch(id: id),
        events: [],
        statistics: [],
        h2hMatches: [],
      );

  static MatchDetail liveMatchDetail({int id = 2}) => MatchDetail(
        match: liveMatch(id: id),
        events: [],
        statistics: [],
        h2hMatches: [],
      );

  static TeamStanding standing({int rank = 1, String group = 'Group A'}) => TeamStanding(
        rank: rank,
        team: homeTeam,
        group: group,
        points: 6,
        played: 2,
        wins: 2,
        draws: 0,
        losses: 0,
        goalsFor: 4,
        goalsAgainst: 1,
      );

  static Map<String, List<Match>> groupedMatches() => {
        'Group A': [finishedMatch(id: 1), upcomingMatch(id: 3)],
        'Group B': [finishedMatch(id: 4)],
      };

  static Map<String, List<TeamStanding>> groupedStandings() => {
        'Group A': [standing(rank: 1), standing(rank: 2, group: 'Group A')],
        'Group B': [standing(rank: 1, group: 'Group B')],
      };
}
