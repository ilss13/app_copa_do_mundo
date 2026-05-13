import 'package:equatable/equatable.dart';

class MatchStatistic extends Equatable {
  const MatchStatistic({
    required this.type,
    required this.homeValue,
    required this.awayValue,
  });

  final String type;
  final String homeValue;
  final String awayValue;

  static List<MatchStatistic> fromTeamJsonPair(
    List<dynamic> homeStats,
    List<dynamic> awayStats,
  ) {
    final homeMap = <String, String>{};
    for (final s in homeStats) {
      final m = s as Map<String, dynamic>;
      homeMap[m['type'] as String? ?? ''] = (m['value'] ?? '0').toString();
    }

    return awayStats.map((s) {
      final m = s as Map<String, dynamic>;
      final type = m['type'] as String? ?? '';
      final away = (m['value'] ?? '0').toString();
      return MatchStatistic(
        type: type,
        homeValue: homeMap[type] ?? '0',
        awayValue: away,
      );
    }).toList();
  }

  double get homeNumeric => double.tryParse(homeValue.replaceAll('%', '')) ?? 0;
  double get awayNumeric => double.tryParse(awayValue.replaceAll('%', '')) ?? 0;

  bool get isPercentage => homeValue.contains('%') || awayValue.contains('%');

  double get homePercent {
    if (isPercentage) return homeNumeric / 100;
    final total = homeNumeric + awayNumeric;
    if (total == 0) return 0.5;
    return homeNumeric / total;
  }

  String get label => _labels[type] ?? type;

  static const _labels = {
    'Shots on Goal': 'Chutes no Gol',
    'Shots off Goal': 'Chutes Fora',
    'Total Shots': 'Total de Chutes',
    'Blocked Shots': 'Chutes Bloqueados',
    'Shots insidebox': 'Chutes Dentro da Área',
    'Shots outsidebox': 'Chutes Fora da Área',
    'Fouls': 'Faltas',
    'Corner Kicks': 'Escanteios',
    'Offsides': 'Impedimentos',
    'Ball Possession': 'Posse de Bola',
    'Yellow Cards': 'Cartões Amarelos',
    'Red Cards': 'Cartões Vermelhos',
    'Goalkeeper Saves': 'Defesas do Goleiro',
    'Total passes': 'Total de Passes',
    'Passes accurate': 'Passes Precisos',
    'Passes %': 'Precisão de Passes',
  };

  @override
  List<Object?> get props => [type, homeValue, awayValue];
}
