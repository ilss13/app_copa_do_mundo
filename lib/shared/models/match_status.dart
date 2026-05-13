enum MatchStatus {
  notStarted,
  firstHalf,
  halftime,
  secondHalf,
  extraTime,
  breakTime,
  penalties,
  finished,
  finishedAET,
  finishedPEN,
  postponed,
  cancelled,
  suspended,
  unknown;

  static MatchStatus fromCode(String code) => switch (code) {
        'NS' || 'TBD' => MatchStatus.notStarted,
        '1H' => MatchStatus.firstHalf,
        'HT' => MatchStatus.halftime,
        '2H' => MatchStatus.secondHalf,
        'ET' => MatchStatus.extraTime,
        'BT' => MatchStatus.breakTime,
        'P' => MatchStatus.penalties,
        'FT' => MatchStatus.finished,
        'AET' => MatchStatus.finishedAET,
        'PEN' => MatchStatus.finishedPEN,
        'PST' => MatchStatus.postponed,
        'CANC' || 'ABD' || 'AWD' || 'WO' => MatchStatus.cancelled,
        'SUSP' || 'INT' => MatchStatus.suspended,
        _ => MatchStatus.unknown,
      };

  bool get isLive => switch (this) {
        firstHalf || halftime || secondHalf || extraTime || breakTime || penalties => true,
        _ => false,
      };

  bool get isFinished => switch (this) {
        finished || finishedAET || finishedPEN => true,
        _ => false,
      };

  bool get isUpcoming => this == notStarted;

  String get shortLabel => switch (this) {
        firstHalf => '1T',
        halftime => 'INT',
        secondHalf => '2T',
        extraTime => 'Prorr.',
        breakTime => 'Pausa',
        penalties => 'Pen.',
        finished => 'Enc.',
        finishedAET => 'Prorr.',
        finishedPEN => 'Pen.',
        postponed => 'Adiado',
        cancelled => 'Cancelado',
        suspended => 'Suspenso',
        _ => '',
      };
}
