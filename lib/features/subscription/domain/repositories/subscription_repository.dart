import 'package:in_app_purchase/in_app_purchase.dart';

abstract interface class SubscriptionRepository {
  Future<bool> checkPremiumStatus();
  Future<List<ProductDetails>> getProducts();
  Future<void> purchase(ProductDetails product);
  Future<void> restorePurchases();
  Stream<bool> get premiumStatusStream;
}
