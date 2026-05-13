import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/matches/presentation/screens/matches_screen.dart';
import '../../features/standings/presentation/screens/standings_screen.dart';
import '../../features/match_detail/presentation/screens/match_detail_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';
import 'main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, _) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => _fade(state, const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.matches,
          pageBuilder: (context, state) => _fade(state, const MatchesScreen()),
        ),
        GoRoute(
          path: AppRoutes.standings,
          pageBuilder: (context, state) => _fade(state, const StandingsScreen()),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.matchDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return MatchDetailScreen(matchId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.subscription,
      builder: (context, state) => const SubscriptionScreen(),
    ),
  ],
);

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
