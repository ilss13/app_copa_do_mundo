import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/team_lineup.dart';
import 'tactical_field.dart';

class LineupsTab extends StatelessWidget {
  const LineupsTab({
    super.key,
    required this.homeLineup,
    required this.awayLineup,
  });

  final TeamLineup? homeLineup;
  final TeamLineup? awayLineup;

  @override
  Widget build(BuildContext context) {
    if (homeLineup == null || awayLineup == null) {
      return Center(
        child: Text(
          'Escalação não disponível',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final home = homeLineup!;
    final away = awayLineup!;

    return ListView(
      children: [
        TacticalField(homeLineup: home, awayLineup: away),
        const SizedBox(height: 16),
        _SubstitutesSection(homeLineup: home, awayLineup: away),
      ],
    );
  }
}

class _SubstitutesSection extends StatelessWidget {
  const _SubstitutesSection({required this.homeLineup, required this.awayLineup});

  final TeamLineup homeLineup;
  final TeamLineup awayLineup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reservas', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _SubList(lineup: homeLineup)),
              const SizedBox(width: 16),
              Expanded(child: _SubList(lineup: awayLineup)),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SubList extends StatelessWidget {
  const _SubList({required this.lineup});

  final TeamLineup lineup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lineup.teamName, style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary)),
        const SizedBox(height: 6),
        ...lineup.substitutes.map(
          (p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Text('${p.number}', style: AppTextStyles.labelSmall),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(p.name, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
