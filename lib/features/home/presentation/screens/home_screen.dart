import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/match.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/match_card_widget.dart';
import '../cubits/home_cubit.dart';
import '../cubits/home_state.dart';
import '../widgets/home_shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            const Text('Copa do Mundo 2026'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_outlined, color: AppColors.secondary),
            onPressed: () => context.push(AppRoutes.subscription),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeInitial() || HomeLoading() => const HomeShimmer(),
            HomeError(:final message) => ErrorStateWidget(
                message: message,
                onRetry: () => context.read<HomeCubit>().load(),
              ),
            HomeEmpty() => const EmptyStateWidget(
                message: 'Nenhum jogo na fase de grupos disponível.',
                icon: Icons.sports_soccer,
              ),
            HomeLoaded() => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      color: AppColors.secondary,
      backgroundColor: AppColors.surface,
      onRefresh: () => context.read<HomeCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _RoundHeader(round: state.currentRound),
          if (state.liveMatches.isNotEmpty) ...[
            _SectionHeader(
              title: 'Ao Vivo',
              icon: Icons.circle,
              iconColor: AppColors.live,
            ),
            ...state.liveMatches.map((m) => _matchCard(context, m)),
          ],
          if (state.upcomingMatches.isNotEmpty) ...[
            _SectionHeader(title: 'Próximos', icon: Icons.schedule),
            ...state.upcomingMatches.map((m) => _matchCard(context, m)),
          ],
          if (state.finishedMatches.isNotEmpty) ...[
            _SectionHeader(title: 'Encerrados', icon: Icons.check_circle_outline),
            ...state.finishedMatches.map((m) => _matchCard(context, m)),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _matchCard(BuildContext context, Match match) {
    return MatchCardWidget(
      match: match,
      onTap: () => context.push(AppRoutes.matchDetailPath(match.id)),
    );
  }
}

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({required this.round});

  final String round;

  @override
  Widget build(BuildContext context) {
    if (round.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        round.toUpperCase(),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.secondary,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon, this.iconColor});

  final String title;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? AppColors.secondary),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: AppTextStyles.labelMedium.copyWith(
              color: iconColor ?? AppColors.secondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
