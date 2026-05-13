import 'match.dart';
import 'team.dart';
import 'match_status.dart';

class FixtureDto {
  const FixtureDto({
    required this.id,
    required this.date,
    required this.statusShort,
    required this.round,
    required this.homeId,
    required this.homeName,
    required this.homeLogo,
    required this.awayId,
    required this.awayName,
    required this.awayLogo,
    this.elapsed,
    this.homeGoals,
    this.awayGoals,
    this.venue,
  });

  final int id;
  final String date;
  final String statusShort;
  final int? elapsed;
  final String round;
  final int homeId;
  final String homeName;
  final String homeLogo;
  final int awayId;
  final String awayName;
  final String awayLogo;
  final int? homeGoals;
  final int? awayGoals;
  final String? venue;

  factory FixtureDto.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>;
    final league = json['league'] as Map<String, dynamic>;
    final teams = json['teams'] as Map<String, dynamic>;
    final home = teams['home'] as Map<String, dynamic>;
    final away = teams['away'] as Map<String, dynamic>;
    final goals = json['goals'] as Map<String, dynamic>;
    final status = fixture['status'] as Map<String, dynamic>;
    final venueMap = fixture['venue'] as Map<String, dynamic>?;

    return FixtureDto(
      id: fixture['id'] as int,
      date: fixture['date'] as String,
      statusShort: status['short'] as String,
      elapsed: status['elapsed'] as int?,
      round: league['round'] as String,
      homeId: home['id'] as int,
      homeName: home['name'] as String,
      homeLogo: home['logo'] as String,
      awayId: away['id'] as int,
      awayName: away['name'] as String,
      awayLogo: away['logo'] as String,
      homeGoals: goals['home'] as int?,
      awayGoals: goals['away'] as int?,
      venue: venueMap != null ? '${venueMap['name']}, ${venueMap['city']}' : null,
    );
  }

  Match toEntity() => Match(
        id: id,
        date: DateTime.parse(date).toLocal(),
        round: round,
        homeTeam: Team(id: homeId, name: homeName, logo: homeLogo),
        awayTeam: Team(id: awayId, name: awayName, logo: awayLogo),
        status: MatchStatus.fromCode(statusShort),
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        elapsed: elapsed,
        venue: venue,
      );
}
