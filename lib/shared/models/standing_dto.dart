import 'team.dart';
import 'team_standing.dart';

class StandingEntryDto {
  const StandingEntryDto({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
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
  final int teamId;
  final String teamName;
  final String teamLogo;
  final String group;
  final int points;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  factory StandingEntryDto.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>;
    final all = json['all'] as Map<String, dynamic>;
    final goals = all['goals'] as Map<String, dynamic>;

    return StandingEntryDto(
      rank: json['rank'] as int,
      teamId: team['id'] as int,
      teamName: team['name'] as String,
      teamLogo: team['logo'] as String,
      group: json['group'] as String,
      points: json['points'] as int,
      played: all['played'] as int,
      wins: all['win'] as int,
      draws: all['draw'] as int,
      losses: all['lose'] as int,
      goalsFor: goals['for'] as int,
      goalsAgainst: goals['against'] as int,
    );
  }

  TeamStanding toEntity() => TeamStanding(
        rank: rank,
        team: Team(id: teamId, name: teamName, logo: teamLogo),
        group: group,
        points: points,
        played: played,
        wins: wins,
        draws: draws,
        losses: losses,
        goalsFor: goalsFor,
        goalsAgainst: goalsAgainst,
      );
}
