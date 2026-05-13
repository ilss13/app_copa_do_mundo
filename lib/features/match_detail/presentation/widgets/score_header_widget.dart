import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/match.dart';
import '../../../../shared/widgets/live_indicator.dart';
import '../../../../shared/widgets/team_logo_widget.dart';

class ScoreHeaderWidget extends StatelessWidget {
  const ScoreHeaderWidget({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        children: [
          if (match.venue != null) ...[
            Text(
              match.venue!,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(child: _TeamColumn(team: match.homeTeam.name, logo: match.homeTeam.logo)),
              _ScoreCenter(match: match),
              Expanded(child: _TeamColumn(team: match.awayTeam.name, logo: match.awayTeam.logo)),
            ],
          ),
          const SizedBox(height: 12),
          _StatusLabel(match: match),
        ],
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({required this.team, required this.logo});

  final String team;
  final String logo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamLogo(url: logo, size: 56),
        const SizedBox(height: 8),
        Text(
          team,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ScoreCenter extends StatelessWidget {
  const _ScoreCenter({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    if (match.isUpcoming) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'VS',
          style: AppTextStyles.displayMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            match.homeGoals?.toString() ?? '-',
            style: match.isLive ? AppTextStyles.scoreLive : AppTextStyles.score,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '–',
              style: AppTextStyles.score.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            match.awayGoals?.toString() ?? '-',
            style: match.isLive ? AppTextStyles.scoreLive : AppTextStyles.score,
          ),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    if (match.isLive) {
      return LiveIndicator(elapsed: match.elapsed);
    }
    if (match.isFinished) {
      return Text(
        match.status.shortLabel,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
      );
    }
    return Text(
      match.round,
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
    );
  }
}
