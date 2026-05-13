import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/match_statistic.dart';

class StatBar extends StatelessWidget {
  const StatBar({super.key, required this.stat});

  final MatchStatistic stat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stat.homeValue, style: AppTextStyles.labelMedium),
              Text(
                stat.label,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
              Text(stat.awayValue, style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 4),
          _BarRow(homePercent: stat.homePercent),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.homePercent});

  final double homePercent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        final gap = 4.0;
        final homeW = (total - gap) * homePercent;
        final awayW = (total - gap) * (1 - homePercent);

        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              width: homeW,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(width: gap),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              width: awayW,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        );
      },
    );
  }
}
