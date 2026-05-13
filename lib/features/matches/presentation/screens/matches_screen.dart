import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/match_card_widget.dart';
import '../../../../shared/widgets/shimmer_box.dart';
import '../cubits/matches_cubit.dart';
import '../cubits/matches_state.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MatchesCubit>()..load(),
      child: const _MatchesView(),
    );
  }
}

class _MatchesView extends StatelessWidget {
  const _MatchesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesCubit, MatchesState>(
      builder: (context, state) {
        return switch (state) {
          MatchesInitial() || MatchesLoading() => const _MatchesShimmer(),
          MatchesError(:final message) => Scaffold(
              appBar: AppBar(title: const Text('Jogos')),
              body: ErrorStateWidget(
                message: message,
                onRetry: () => context.read<MatchesCubit>().load(),
              ),
            ),
          MatchesLoaded() => _MatchesTabs(state: state),
        };
      },
    );
  }
}

class _MatchesTabs extends StatelessWidget {
  const _MatchesTabs({required this.state});

  final MatchesLoaded state;

  @override
  Widget build(BuildContext context) {
    final groups = state.groups;

    return DefaultTabController(
      length: groups.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jogos'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: groups
                .map((g) => Tab(text: _shortGroupName(g)))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: groups.map((group) {
            final matches = state.grouped[group]!;
            return RefreshIndicator(
              color: AppColors.secondary,
              backgroundColor: AppColors.surface,
              onRefresh: () => context.read<MatchesCubit>().refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: matches.length,
                itemBuilder: (_, i) => MatchCardWidget(
                  match: matches[i],
                  onTap: () => context.push(AppRoutes.matchDetailPath(matches[i].id)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _shortGroupName(String group) {
    if (group.startsWith('Group ')) return group.replaceFirst('Group ', 'Grupo ');
    return group;
  }
}

class _MatchesShimmer extends StatelessWidget {
  const _MatchesShimmer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: ShimmerBox(width: 60, height: 24, borderRadius: 4),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: List.generate(5, (_) => const ShimmerCard(height: 100)),
      ),
    );
  }
}
