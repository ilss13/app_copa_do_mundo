import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/team_standing.dart';
import '../../../../shared/widgets/team_logo_widget.dart';

class GroupStandingsTable extends StatelessWidget {
  const GroupStandingsTable({super.key, required this.standings});

  final List<TeamStanding> standings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.divider),
          ...standings.asMap().entries.map((e) => _buildRow(e.value, e.key)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _headerCell('#', width: 20),
          const SizedBox(width: 36),
          Expanded(child: _headerCell('Time', align: TextAlign.left)),
          _headerCell('P', width: 28),
          _headerCell('J', width: 28),
          _headerCell('V', width: 28),
          _headerCell('E', width: 28),
          _headerCell('D', width: 28),
          _headerCell('SG', width: 32),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {double? width, TextAlign align = TextAlign.center}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w700,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildRow(TeamStanding s, int index) {
    // Top 2 qualificam-se, destaque em verde
    final isQualified = s.rank <= 2;
    final bgColor = isQualified
        ? AppColors.success.withValues(alpha: 0.08)
        : Colors.transparent;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Rank com indicador de qualificação
          SizedBox(
            width: 20,
            child: Text(
              '${s.rank}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isQualified ? AppColors.success : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          TeamLogo(url: s.team.logo, size: 24),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              s.team.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: isQualified ? FontWeight.w600 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _dataCell('${s.points}', bold: true),
          _dataCell('${s.played}'),
          _dataCell('${s.wins}'),
          _dataCell('${s.draws}'),
          _dataCell('${s.losses}'),
          _dataCell(
            s.goalDiff >= 0 ? '+${s.goalDiff}' : '${s.goalDiff}',
            color: s.goalDiff > 0
                ? AppColors.success
                : s.goalDiff < 0
                    ? AppColors.live
                    : AppColors.textSecondary,
            width: 32,
          ),
        ],
      ),
    );
  }

  Widget _dataCell(String text, {double width = 28, bool bold = false, Color? color}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color ?? AppColors.textPrimary,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
