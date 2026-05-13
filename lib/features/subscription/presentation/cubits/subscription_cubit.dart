import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_state.dart';

@lazySingleton
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this._repository, this._analytics)
      : super(const SubscriptionState()) {
    _premiumSub = _repository.premiumStatusStream.listen((isPremium) {
      if (isPremium && _pendingProductId != null) {
        unawaited(_analytics.logSubscriptionConverted(_pendingProductId!));
        _pendingProductId = null;
      }
      emit(state.copyWith(isPremium: isPremium, status: SubscriptionStatus.idle));
    });
    _init();
  }

  final SubscriptionRepository _repository;
  final AnalyticsService _analytics;
  StreamSubscription<bool>? _premiumSub;
  String? _pendingProductId;

  bool get isPremium => state.isPremium;

  Future<void> _init() async {
    if (isClosed) return;
    emit(state.copyWith(status: SubscriptionStatus.loading));
    final results = await Future.wait([
      _repository.checkPremiumStatus(),
      _repository.getProducts(),
    ]);
    if (isClosed) return;
    emit(state.copyWith(
      isPremium: results[0] as bool,
      products: results[1] as List<ProductDetails>,
      status: SubscriptionStatus.idle,
    ));
  }

  Future<void> purchase(ProductDetails product) async {
    _pendingProductId = product.id;
    emit(state.copyWith(status: SubscriptionStatus.purchasing, errorMessage: null));
    unawaited(_analytics.logSubscriptionStarted(product.id));
    try {
      await _repository.purchase(product);
    } catch (e) {
      _pendingProductId = null;
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: _friendlyError(e),
      ));
    }
  }

  Future<void> restorePurchases() async {
    emit(state.copyWith(status: SubscriptionStatus.purchasing, errorMessage: null));
    try {
      await _repository.restorePurchases();
      emit(state.copyWith(status: SubscriptionStatus.idle));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: _friendlyError(e),
      ));
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('canceled') || msg.contains('cancel')) {
      return 'Compra cancelada.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Sem conexão. Tente novamente.';
    }
    return 'Erro ao processar compra. Tente novamente.';
  }

  @override
  Future<void> close() {
    _premiumSub?.cancel();
    return super.close();
  }
}
