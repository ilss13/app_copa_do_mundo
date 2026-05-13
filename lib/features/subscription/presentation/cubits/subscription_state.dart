import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum SubscriptionStatus { idle, loading, purchasing, error }

class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.isPremium = false,
    this.status = SubscriptionStatus.idle,
    this.products = const [],
    this.errorMessage,
  });

  final bool isPremium;
  final SubscriptionStatus status;
  final List<ProductDetails> products;
  final String? errorMessage;

  bool get isLoading => status == SubscriptionStatus.loading;
  bool get isPurchasing => status == SubscriptionStatus.purchasing;

  SubscriptionState copyWith({
    bool? isPremium,
    SubscriptionStatus? status,
    List<ProductDetails>? products,
    String? errorMessage,
  }) => SubscriptionState(
    isPremium: isPremium ?? this.isPremium,
    status: status ?? this.status,
    products: products ?? this.products,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [isPremium, status, products, errorMessage];
}
