import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/models/match.dart';
import '../../../../shared/models/team.dart';
import '../../../../shared/widgets/team_logo_widget.dart';

class BracketTab extends StatelessWidget {
  const BracketTab({super.key, required this.grouped});

  final Map<String, List<Match>> grouped;

  static const _roundOrder = [
    ('Round of 32', 'Round of 32'),
    ('Round of 16', 'Oitavas'),
    ('Quarter-finals', 'Quartas'),
    ('Semi-finals', 'Semifinais'),
    ('Final', 'Final'),
  ];

  static const _cardH = 80.0;
  static const _cardW = 160.0;
  static const _colGap = 36.0;
  static const _headerH = 40.0;
  static const _baseGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final activeRounds = _roundOrder
        .where((r) => grouped[r.$1]?.isNotEmpty ?? false)
        .map((r) {
          final matches = List<Match>.from(grouped[r.$1]!)
            ..sort((a, b) => a.id.compareTo(b.id));
          return (r.$2, matches);
        })
        .toList();

    if (activeRounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Chaveamento disponível\napós a fase de grupos',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final baseCount = activeRounds.first.$2.length;
    final totalBracketH = baseCount * (_cardH + _baseGap);
    final totalW =
        activeRounds.length * _cardW + (activeRounds.length - 1) * _colGap;
    final totalH = _headerH + totalBracketH;
    final roundCounts = activeRounds.map((r) => r.$2.length).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SingleChildScrollView(
        child: SizedBox(
          width: totalW,
          height: totalH,
          child: CustomPaint(
            painter: _BracketLinePainter(
              roundCounts: roundCounts,
              totalBracketH: totalBracketH,
              cardH: _cardH,
              cardW: _cardW,
              colGap: _colGap,
              headerH: _headerH,
            ),
            child: Stack(
              children: [
                for (var c = 0; c < activeRounds.length; c++)
                  Positioned(
                    left: c * (_cardW + _colGap),
                    top: 0,
                    width: _cardW,
                    height: _headerH,
                    child: Center(
                      child: Text(
                        activeRounds[c].$1,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                for (var c = 0; c < activeRounds.length; c++)
                  for (var m = 0; m < activeRounds[c].$2.length; m++)
                    Positioned(
                      left: c * (_cardW + _colGap),
                      top: _headerH +
                          _matchTop(
                            m,
                            activeRounds[c].$2.length,
                            totalBracketH,
                          ),
                      width: _cardW,
                      height: _cardH,
                      child: _BracketMatchCard(
                        match: activeRounds[c].$2[m],
                        onTap: () => context.push(
                          AppRoutes.matchDetailPath(activeRounds[c].$2[m].id),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static double _matchTop(int index, int count, double totalH) {
    final slot = totalH / count;
    return index * slot + (slot - _cardH) / 2;
  }
}

class _BracketLinePainter extends CustomPainter {
  _BracketLinePainter({
    required this.roundCounts,
    required this.totalBracketH,
    required this.cardH,
    required this.cardW,
    required this.colGap,
    required this.headerH,
  });

  final List<int> roundCounts;
  final double totalBracketH;
  final double cardH;
  final double cardW;
  final double colGap;
  final double headerH;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var c = 0; c < roundCounts.length - 1; c++) {
      final srcCount = roundCounts[c];
      final tgtCount = roundCounts[c + 1];
      final srcLeftX = c * (cardW + colGap);
      final tgtLeftX = (c + 1) * (cardW + colGap);
      final midX = srcLeftX + cardW + colGap / 2;

      for (var i = 0; i < tgtCount; i++) {
        final src1 = i * 2;
        final src2 = i * 2 + 1;
        if (src2 >= srcCount) continue;

        final src1CY = headerH + _centerY(src1, srcCount);
        final src2CY = headerH + _centerY(src2, srcCount);
        final tgtCY = headerH + _centerY(i, tgtCount);

        canvas.drawLine(
          Offset(srcLeftX + cardW, src1CY),
          Offset(midX, src1CY),
          paint,
        );
        canvas.drawLine(
          Offset(srcLeftX + cardW, src2CY),
          Offset(midX, src2CY),
          paint,
        );
        canvas.drawLine(Offset(midX, src1CY), Offset(midX, src2CY), paint);
        canvas.drawLine(Offset(midX, tgtCY), Offset(tgtLeftX, tgtCY), paint);
      }
    }
  }

  double _centerY(int index, int count) {
    final slot = totalBracketH / count;
    return (index + 0.5) * slot;
  }

  @override
  bool shouldRepaint(covariant _BracketLinePainter old) =>
      !listEquals(old.roundCounts, roundCounts) ||
      old.totalBracketH != totalBracketH;
}

class _BracketMatchCard extends StatelessWidget {
  const _BracketMatchCard({required this.match, required this.onTap});

  final Match match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: match.isLive ? AppColors.secondary : AppColors.cardBorder,
            width: match.isLive ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TeamRow(team: match.homeTeam, goals: match.homeGoals),
            Divider(height: 1, thickness: 0.5, color: AppColors.divider),
            _TeamRow(team: match.awayTeam, goals: match.awayGoals),
            if (match.isUpcoming)
              Text(
                match.date.formattedDateTime,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.team, required this.goals});

  final Team team;
  final int? goals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TeamLogo(url: team.logo, size: 16),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            team.name,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (goals != null)
          Text('$goals', style: AppTextStyles.labelMedium),
      ],
    );
  }
}
