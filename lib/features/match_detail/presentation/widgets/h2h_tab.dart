import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/match.dart';
import '../../../../shared/widgets/team_logo_widget.dart';
import '../cubits/match_detail_cubit.dart';
import 'premium_lock_widget.dart';

class H2HTab extends StatefulWidget {
  const H2HTab({
    super.key,
    required this.h2hMatches,
    required this.isPremium,
    required this.currentMatch,
  });

  final List<Match> h2hMatches;
  final bool isPremium;
  final Match currentMatch;

  @override
  State<H2HTab> createState() => _H2HTabState();
}

class _H2HTabState extends State<H2HTab> {
  @override
  void initState() {
    super.initState();
    if (!widget.isPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<MatchDetailCubit>().logH2HBlocked();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPremium) return const PremiumLockWidget();

    if (widget.h2hMatches.isEmpty) {
      return Center(
        child: Text(
          'Sem confrontos anteriores',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.h2hMatches.length,
      separatorBuilder: (_, _) => Divider(color: AppColors.divider, height: 1),
      itemBuilder: (_, i) => _H2HMatchTile(
        match: widget.h2hMatches[i],
        homeId: widget.currentMatch.homeTeam.id,
      ),
    );
  }
}

class _H2HMatchTile extends StatelessWidget {
  const _H2HMatchTile({required this.match, required this.homeId});

  final Match match;
  final int homeId;

  @override
  Widget build(BuildContext context) {
    final homeGoals = match.homeGoals ?? 0;
    final awayGoals = match.awayGoals ?? 0;
    Color resultColor;
    if (match.homeTeam.id == homeId) {
      resultColor = homeGoals > awayGoals
          ? AppColors.success
          : homeGoals < awayGoals
              ? AppColors.error
              : AppColors.textSecondary;
    } else {
      resultColor = awayGoals > homeGoals
          ? AppColors.success
          : awayGoals < homeGoals
              ? AppColors.error
              : AppColors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                TeamLogo(url: match.homeTeam.logo, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    match.homeTeam.name,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: resultColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${match.homeGoals ?? '-'} – ${match.awayGoals ?? '-'}',
              style: AppTextStyles.labelMedium.copyWith(color: resultColor),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    match.awayTeam.name,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                TeamLogo(url: match.awayTeam.logo, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
