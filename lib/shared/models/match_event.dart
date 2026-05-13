import 'package:equatable/equatable.dart';

enum MatchEventType {
  goal,
  ownGoal,
  penalty,
  missedPenalty,
  yellowCard,
  redCard,
  yellowRedCard,
  substitution,
  var_,
  unknown;

  static MatchEventType fromApi({required String type, required String detail}) {
    final t = type.toLowerCase();
    final d = detail.toLowerCase();
    if (t == 'goal') {
      if (d.contains('own goal')) return ownGoal;
      if (d.contains('penalty')) return penalty;
      if (d.contains('missed penalty')) return missedPenalty;
      return goal;
    }
    if (t == 'card') {
      if (d.contains('red card') && d.contains('yellow')) return yellowRedCard;
      if (d.contains('red')) return redCard;
      return yellowCard;
    }
    if (t == 'subst') return substitution;
    if (t == 'var') return var_;
    return unknown;
  }

  bool get isGoalLike => this == goal || this == ownGoal || this == penalty;
  bool get isCard => this == yellowCard || this == redCard || this == yellowRedCard;
}

class MatchEvent extends Equatable {
  const MatchEvent({
    required this.elapsed,
    required this.teamId,
    required this.type,
    required this.playerName,
    this.assistName,
    this.extraTime,
  });

  final int elapsed;
  final int teamId;
  final MatchEventType type;
  final String playerName;
  final String? assistName;
  final int? extraTime;

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    final teamId = (json['team'] as Map<String, dynamic>? ?? {})['id'] as int? ?? 0;
    final player = (json['player'] as Map<String, dynamic>? ?? {})['name'] as String? ?? '';
    final assist = (json['assist'] as Map<String, dynamic>? ?? {})['name'] as String?;
    final type = json['type'] as String? ?? '';
    final detail = json['detail'] as String? ?? '';
    final time = json['time'] as Map<String, dynamic>? ?? {};
    return MatchEvent(
      elapsed: time['elapsed'] as int? ?? 0,
      extraTime: time['extra'] as int?,
      teamId: teamId,
      type: MatchEventType.fromApi(type: type, detail: detail),
      playerName: player,
      assistName: (assist?.isNotEmpty ?? false) ? assist : null,
    );
  }

  @override
  List<Object?> get props => [elapsed, teamId, type, playerName, extraTime];
}
