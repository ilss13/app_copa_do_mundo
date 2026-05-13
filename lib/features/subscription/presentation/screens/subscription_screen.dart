import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubits/subscription_cubit.dart';
import '../cubits/subscription_state.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        actions: [
          TextButton(
            onPressed: () => context.read<SubscriptionCubit>().restorePurchases(),
            child: Text(
              'Restaurar',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listenWhen: (prev, curr) => curr.isPremium && !prev.isPremium,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bem-vindo ao Premium!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        },
        builder: (context, state) {
          if (state.isPremium) return const _PremiumActiveView();
          if (state.isLoading) return const _LoadingView();
          return _PaywallView(state: state);
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
  }
}

class _PremiumActiveView extends StatelessWidget {
  const _PremiumActiveView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: AppColors.secondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text('Você é Premium!', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 12),
            Text(
              'Aproveite o acesso completo ao histórico H2H e navegação sem anúncios.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaywallView extends StatelessWidget {
  const _PaywallView({required this.state});

  final SubscriptionState state;

  @override
  Widget build(BuildContext context) {
    final monthly = _findProduct(state.products, AppConfig.productMonthlyId);
    final yearly = _findProduct(state.products, AppConfig.productYearlyId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroSection().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
          const SizedBox(height: 28),
          _BenefitsList().animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 28),
          if (state.products.isEmpty) ...[
            _UnavailableNotice(),
          ] else ...[
            if (yearly != null)
              _PlanCard(
                product: yearly,
                isHighlighted: true,
                badge: 'Mais popular',
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 12),
            if (monthly != null)
              _PlanCard(
                product: monthly,
                isHighlighted: false,
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Assinatura renovada automaticamente. Cancele quando quiser na loja do seu dispositivo.',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  ProductDetails? _findProduct(List<ProductDetails> products, String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.secondaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.workspace_premium, color: Colors.black, size: 44),
        ),
        const SizedBox(height: 20),
        Text(
          'Copa do Mundo Premium',
          style: AppTextStyles.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Desbloqueie tudo e viva a Copa sem limites.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BenefitsList extends StatelessWidget {
  static const _benefits = [
    (Icons.compare_arrows_rounded, 'Histórico H2H completo', 'Confrontos diretos sem restrição'),
    (Icons.block, 'Sem anúncios', 'Experiência limpa, sem interrupções'),
    (Icons.notifications_active, 'Alertas ao vivo', 'Notificações de gols e eventos'),
    (Icons.auto_graph, 'Estatísticas avançadas', 'Dados completos de cada partida'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: _benefits.map((b) => _BenefitItem(b.$1, b.$2, b.$3)).toList(),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.product,
    required this.isHighlighted,
    this.badge,
  });

  final ProductDetails product;
  final bool isHighlighted;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => context.read<SubscriptionCubit>().purchase(product),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.secondary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHighlighted ? AppColors.secondary : AppColors.cardBorder,
                width: isHighlighted ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _planLabel(product.id),
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.price,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: isHighlighted ? AppColors.secondary : AppColors.textPrimary,
                        ),
                      ),
                      if (_periodLabel(product.id).isNotEmpty)
                        Text(
                          _periodLabel(product.id),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                BlocBuilder<SubscriptionCubit, SubscriptionState>(
                  builder: (context, state) {
                    if (state.isPurchasing) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      );
                    }
                    return FilledButton(
                      onPressed: () => context.read<SubscriptionCubit>().purchase(product),
                      style: FilledButton.styleFrom(
                        backgroundColor: isHighlighted ? AppColors.secondary : AppColors.primaryLight,
                        foregroundColor: isHighlighted ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Assinar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _planLabel(String id) {
    if (id == AppConfig.productYearlyId) return 'Anual';
    if (id == AppConfig.productMonthlyId) return 'Mensal';
    return id;
  }

  String _periodLabel(String id) {
    if (id == AppConfig.productYearlyId) return 'cobrado por ano';
    if (id == AppConfig.productMonthlyId) return 'cobrado por mês';
    return '';
  }
}

class _UnavailableNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.store_mall_directory_outlined, color: AppColors.textSecondary, size: 32),
          const SizedBox(height: 12),
          Text(
            'Loja indisponível',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Não foi possível carregar os planos. Verifique sua conexão e tente novamente.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
