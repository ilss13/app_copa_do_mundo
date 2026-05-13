import 'package:equatable/equatable.dart';

import 'lineup_player.dart';

class TeamLineup extends Equatable {
  const TeamLineup({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.formation,
    required this.startXI,
    required this.substitutes,
    this.coachName,
  });

  final int teamId;
  final String teamName;
  final String teamLogo;
  final String formation;
  final List<LineupPlayer> startXI;
  final List<LineupPlayer> substitutes;
  final String? coachName;

  factory TeamLineup.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>? ?? {};
    final coach = json['coach'] as Map<String, dynamic>? ?? {};
    final startRaw = json['startXI'] as List<dynamic>? ?? [];
    final subsRaw = json['substitutes'] as List<dynamic>? ?? [];

    return TeamLineup(
      teamId: team['id'] as int? ?? 0,
      teamName: team['name'] as String? ?? '',
      teamLogo: team['logo'] as String? ?? '',
      formation: json['formation'] as String? ?? '',
      coachName: coach['name'] as String?,
      startXI: startRaw
          .map((e) => LineupPlayer.fromJson((e as Map<String, dynamic>)['player'] as Map<String, dynamic>? ?? {}))
          .toList(),
      substitutes: subsRaw
          .map((e) => LineupPlayer.fromJson((e as Map<String, dynamic>)['player'] as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [teamId, formation];
}
