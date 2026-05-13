import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/shimmer_box.dart';
import '../../../subscription/presentation/cubits/subscription_cubit.dart';
import '../cubits/match_detail_cubit.dart';
import '../cubits/match_detail_state.dart';
import '../widgets/events_list_widget.dart';
import '../widgets/h2h_tab.dart';
import '../widgets/lineups_tab.dart';
import '../widgets/score_header_widget.dart';
import '../widgets/statistics_tab.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final int matchId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MatchDetailCubit>()..load(matchId),
      child: const _MatchDetailView(),
    );
  }
}

class _MatchDetailView extends StatelessWidget {
  const _MatchDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchDetailCubit, MatchDetailState>(
      builder: (context, state) {
        return switch (state) {
          MatchDetailInitial() || MatchDetailLoading() => const _LoadingScaffold(),
          MatchDetailError(:final message) => Scaffold(
              appBar: AppBar(title: const Text('Jogo')),
              body: ErrorStateWidget(
                message: message,
                onRetry: () => context.read<MatchDetailCubit>().refresh(),
              ),
            ),
          MatchDetailLoaded() => _LoadedView(state: state),
        };
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});

  final MatchDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    final match = detail.match;
    final isPremium = context.watch<SubscriptionCubit>().isPremium;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${match.homeTeam.name} vs ${match.awayTeam.name}',
            style: AppTextStyles.headlineSmall,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Eventos'),
              Tab(text: 'Escalação'),
              Tab(text: 'Estatísticas'),
              Tab(text: 'H2H'),
            ],
          ),
        ),
        body: Column(
          children: [
            ScoreHeaderWidget(match: match),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.secondary,
                backgroundColor: AppColors.surface,
                onRefresh: () => context.read<MatchDetailCubit>().refresh(),
                child: TabBarView(
                  children: [
                    EventsListWidget(events: detail.events, match: match),
                    LineupsTab(homeLineup: detail.homeLineup, awayLineup: detail.awayLineup),
                    StatisticsTab(statistics: detail.statistics, match: match, isPremium: isPremium),
                    H2HTab(
                      h2hMatches: detail.h2hMatches,
                      isPremium: isPremium,
                      currentMatch: match,
                    ),
                  ],
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: ShimmerBox(width: 64, height: 16)),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          ShimmerCard(height: 140),
          const SizedBox(height: 8),
          ...List.generate(6, (_) => const ShimmerCard(height: 48)),
        ],
      ),
    );
  }
}
