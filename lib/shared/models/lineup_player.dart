import 'package:equatable/equatable.dart';

class LineupPlayer extends Equatable {
  const LineupPlayer({
    required this.id,
    required this.name,
    required this.number,
    required this.pos,
    required this.gridCol,
    required this.gridRow,
  });

  final int id;
  final String name;
  final int number;
  final String pos;
  final int gridCol;
  final int gridRow;

  factory LineupPlayer.fromJson(Map<String, dynamic> json) {
    final grid = json['grid'] as String? ?? '1:1';
    final parts = grid.split(':');
    final col = int.tryParse(parts.isNotEmpty ? parts[0] : '1') ?? 1;
    final row = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;
    return LineupPlayer(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      number: json['number'] as int? ?? 0,
      pos: json['pos'] as String? ?? '',
      gridCol: col,
      gridRow: row,
    );
  }

  String get shortName {
    final parts = name.split(' ');
    if (parts.length <= 1) return name;
    return parts.last;
  }

  @override
  List<Object?> get props => [id, number, gridCol, gridRow];
}
