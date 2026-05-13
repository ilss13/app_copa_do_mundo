import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/lineup_player.dart';
import '../../../../shared/models/team_lineup.dart';

class TacticalField extends StatelessWidget {
  const TacticalField({
    super.key,
    required this.homeLineup,
    required this.awayLineup,
  });

  final TeamLineup homeLineup;
  final TeamLineup awayLineup;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.6,
      child: CustomPaint(
        painter: _FieldPainter(),
        child: Column(
          children: [
            _FormationBar(lineup: awayLineup, isHome: false),
            Expanded(
              child: Stack(
                children: [
                  _PlayerPositions(lineup: awayLineup, isHome: false),
                  _PlayerPositions(lineup: homeLineup, isHome: true),
                ],
              ),
            ),
            _FormationBar(lineup: homeLineup, isHome: true),
          ],
        ),
      ),
    );
  }
}

class _FormationBar extends StatelessWidget {
  const _FormationBar({required this.lineup, required this.isHome});

  final TeamLineup lineup;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: isHome ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!isHome) ...[
            Text(lineup.teamName, style: AppTextStyles.labelSmall),
            const SizedBox(width: 6),
            Text(lineup.formation, style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary)),
          ] else ...[
            Text(lineup.formation, style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary)),
            const SizedBox(width: 6),
            Text(lineup.teamName, style: AppTextStyles.labelSmall),
          ],
        ],
      ),
    );
  }
}

class _PlayerPositions extends StatelessWidget {
  const _PlayerPositions({required this.lineup, required this.isHome});

  final TeamLineup lineup;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final maxCol = lineup.startXI.map((p) => p.gridCol).fold(1, (a, b) => a > b ? a : b);
        final maxRow = lineup.startXI.map((p) => p.gridRow).fold(1, (a, b) => a > b ? a : b);

        return Stack(
          children: lineup.startXI.map((player) {
            final colFraction = (player.gridCol - 0.5) / maxCol;
            final rowFraction = (player.gridRow - 0.5) / maxRow;

            final x = colFraction * w;
            final y = isHome
                ? h - rowFraction * h
                : rowFraction * h;

            return Positioned(
              left: x - 20,
              top: y - 20,
              child: _PlayerDot(player: player, isHome: isHome),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PlayerDot extends StatelessWidget {
  const _PlayerDot({required this.player, required this.isHome});

  final LineupPlayer player;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final color = isHome ? AppColors.primary : AppColors.primaryDark;
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary, width: 1.5),
            ),
            child: Center(
              child: Text(
                '${player.number}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            player.shortName,
            style: AppTextStyles.labelSmall.copyWith(fontSize: 8),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grass = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawRect(Offset.zero & size, grass);

    _drawStripes(canvas, size);
    _drawLines(canvas, size);
  }

  void _drawStripes(Canvas canvas, Size size) {
    final stripe1 = Paint()..color = const Color(0xFF1E6823);
    final stripeWidth = size.width / 8;
    for (int i = 0; i < 8; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(i * stripeWidth, 0, stripeWidth, size.height),
          stripe1,
        );
      }
    }
  }

  void _drawLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Outer border
    canvas.drawRect(
      Rect.fromLTRB(8, 8, size.width - 8, size.height - 8),
      linePaint,
    );

    // Halfway line
    canvas.drawLine(
      Offset(8, size.height / 2),
      Offset(size.width - 8, size.height / 2),
      linePaint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.12,
      linePaint,
    );

    // Center dot
    final dot = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3, dot);

    // Penalty areas (top and bottom)
    final penW = size.width * 0.55;
    final penH = size.height * 0.12;
    final penLeft = (size.width - penW) / 2;

    // Top penalty area
    canvas.drawRect(
      Rect.fromLTWH(penLeft, 8, penW, penH),
      linePaint,
    );
    // Bottom penalty area
    canvas.drawRect(
      Rect.fromLTWH(penLeft, size.height - 8 - penH, penW, penH),
      linePaint,
    );

    // Goal areas (6-yard boxes)
    final goalW = size.width * 0.25;
    final goalH = size.height * 0.05;
    final goalLeft = (size.width - goalW) / 2;

    canvas.drawRect(Rect.fromLTWH(goalLeft, 8, goalW, goalH), linePaint);
    canvas.drawRect(
      Rect.fromLTWH(goalLeft, size.height - 8 - goalH, goalW, goalH),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
