import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'app_routes.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexFromRoute(location),
        onTap: (i) => _onNavTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            activeIcon: Icon(Icons.today),
            label: 'Hoje',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer_outlined),
            activeIcon: Icon(Icons.sports_soccer),
            label: 'Jogos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'Tabela',
          ),
        ],
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
      ),
    );
  }

  int _indexFromRoute(String location) {
    if (location.startsWith(AppRoutes.matches)) return 1;
    if (location.startsWith(AppRoutes.standings)) return 2;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    final routes = [AppRoutes.home, AppRoutes.matches, AppRoutes.standings];
    context.go(routes[index]);
  }
}
