import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/extensions/date_extensions.dart';
import '../../shared/models/match.dart';
import 'live_indicator.dart';
import 'team_logo_widget.dart';

class MatchCardWidget extends StatelessWidget {
  const MatchCardWidget({super.key, required this.match, this.onTap});

  final Match match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: match.isLive ? AppColors.liveBorder : AppColors.cardBorder,
            width: match.isLive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: match.isLive
                  ? AppColors.secondary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.25),
              blurRadius: match.isLive ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildTopRow(),
              const SizedBox(height: 10),
              _buildTeamsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          match.round,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
        if (match.isLive)
          LiveIndicator(elapsed: match.elapsed)
        else if (match.isFinished)
          Text(
            match.status.shortLabel,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          )
        else
          Text(
            match.date.formattedDate,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildTeamsRow() {
    return Row(
      children: [
        Expanded(child: _buildTeamSide(match.homeTeam.logo, match.homeTeam.name, isHome: true)),
        _buildScoreOrTime(),
        Expanded(child: _buildTeamSide(match.awayTeam.logo, match.awayTeam.name, isHome: false)),
      ],
    );
  }

  Widget _buildTeamSide(String logo, String name, {required bool isHome}) {
    return Column(
      children: [
        TeamLogo(url: logo, size: 40),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildScoreOrTime() {
    if (match.isLive || match.isFinished) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _scoreText(match.homeGoals),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '–',
                style: AppTextStyles.score.copyWith(color: AppColors.textSecondary),
              ),
            ),
            _scoreText(match.awayGoals),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            match.date.formattedTime,
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 2),
          Text(
            'vs',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }

  Widget _scoreText(int? goals) {
    return Text(
      goals?.toString() ?? '-',
      style: AppTextStyles.score.copyWith(
        color: match.isLive ? AppColors.secondary : AppColors.textPrimary,
      ),
    );
  }
}
