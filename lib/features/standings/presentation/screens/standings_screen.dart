import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/shimmer_box.dart';
import '../cubits/standings_cubit.dart';
import '../cubits/standings_state.dart';
import '../widgets/group_standings_table.dart';

class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StandingsCubit>()..load(),
      child: const _StandingsView(),
    );
  }
}

class _StandingsView extends StatelessWidget {
  const _StandingsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StandingsCubit, StandingsState>(
      builder: (context, state) {
        return switch (state) {
          StandingsInitial() || StandingsLoading() => const _StandingsShimmer(),
          StandingsError(:final message) => Scaffold(
              appBar: AppBar(title: const Text('Tabela')),
              body: ErrorStateWidget(
                message: message,
                onRetry: () => context.read<StandingsCubit>().load(),
              ),
            ),
          StandingsLoaded() => _StandingsTabs(state: state),
        };
      },
    );
  }
}

class _StandingsTabs extends StatelessWidget {
  const _StandingsTabs({required this.state});

  final StandingsLoaded state;

  @override
  Widget build(BuildContext context) {
    final groups = state.groups;

    return DefaultTabController(
      length: groups.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabela'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: groups.map((g) => Tab(text: _shortName(g))).toList(),
          ),
        ),
        body: TabBarView(
          children: groups.map((group) {
            final standings = state.grouped[group]!;
            return RefreshIndicator(
              color: AppColors.secondary,
              backgroundColor: AppColors.surface,
              onRefresh: () => context.read<StandingsCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  GroupStandingsTable(standings: standings),
                  const SizedBox(height: 8),
                  _buildLegend(),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _legendDot(AppColors.success),
          const SizedBox(width: 6),
          const Text(
            'Classificado',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  String _shortName(String group) {
    if (group.startsWith('Group ')) return group.replaceFirst('Group ', 'Grupo ');
    return group;
  }
}

class _StandingsShimmer extends StatelessWidget {
  const _StandingsShimmer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabela'),
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
        children: List.generate(
          3,
          (_) => const ShimmerCard(height: 180),
        ),
      ),
    );
  }
}
