import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/match.dart';
import '../../../../shared/models/match_statistic.dart';
import '../../../../shared/widgets/team_logo_widget.dart';
import 'premium_lock_widget.dart';
import 'stat_bar.dart';

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({
    super.key,
    required this.statistics,
    required this.match,
    required this.isPremium,
  });

  final List<MatchStatistic> statistics;
  final Match match;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    if (!isPremium) return const PremiumLockWidget();

    if (statistics.isEmpty) {
      return Center(
        child: Text(
          'Estatísticas não disponíveis',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        _TeamHeader(match: match),
        const SizedBox(height: 12),
        ...statistics.map((s) => StatBar(stat: s)),
      ],
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            TeamLogo(url: match.homeTeam.logo, size: 24),
            const SizedBox(width: 6),
            Text(match.homeTeam.name, style: AppTextStyles.labelMedium),
          ]),
          Row(children: [
            Text(match.awayTeam.name, style: AppTextStyles.labelMedium),
            const SizedBox(width: 6),
            TeamLogo(url: match.awayTeam.logo, size: 24),
          ]),
        ],
      ),
    );
  }
}
