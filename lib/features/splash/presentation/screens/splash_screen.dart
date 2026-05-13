import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.background],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy icon
              const Icon(
                Icons.emoji_events,
                color: AppColors.secondary,
                size: 80,
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              Text(
                'COPA DO MUNDO',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.secondary,
                  letterSpacing: 3,
                ),
              )
                  .animate()
                  .slideY(begin: 0.3, duration: 500.ms, delay: 300.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 500.ms, delay: 300.ms),
              const SizedBox(height: 8),
              Text(
                '2026',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 8,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms),
              const SizedBox(height: 60),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}
