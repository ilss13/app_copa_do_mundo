import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/repositories/subscription_repository.dart';

@LazySingleton(as: SubscriptionRepository)
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._auth, this._firestore) {
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchases,
    );
    _ensureAnonymousAuth();
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final _premiumController = StreamController<bool>.broadcast();

  static const _productIds = {
    AppConfig.productMonthlyId,
    AppConfig.productYearlyId,
  };

  @override
  Stream<bool> get premiumStatusStream => _premiumController.stream;

  @override
  Future<bool> checkPremiumStatus() async {
    final user = _auth.currentUser ?? await _ensureAnonymousAuth();
    if (user == null) return false;
    try {
      final doc = await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(user.uid)
          .get();
      if (!doc.exists) return false;
      final sub = doc.data()?['subscription'] as Map<String, dynamic>?;
      if (sub == null || sub['status'] != 'premium') return false;
      final expiresAt = sub['expiresAt'] as Timestamp?;
      if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<ProductDetails>> getProducts() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return [];
    final response = await InAppPurchase.instance.queryProductDetails(
      _productIds,
    );
    return response.productDetails;
  }

  @override
  Future<void> purchase(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  @override
  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  Future<User?> _ensureAnonymousAuth() async {
    try {
      if (_auth.currentUser != null) return _auth.currentUser;
      final cred = await _auth.signInAnonymously();
      return cred.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _persistPremium();
        _premiumController.add(true);
      }
    }
  }

  Future<void> _persistPremium() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final expiresAt = DateTime.now().add(const Duration(days: 32));
    await _firestore
        .collection(AppConfig.firestoreUsersCollection)
        .doc(uid)
        .set({
          'subscription': {
            'status': 'premium',
            'expiresAt': Timestamp.fromDate(expiresAt),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        }, SetOptions(merge: true));
  }

  @disposeMethod
  void dispose() {
    _purchaseSub?.cancel();
    _premiumController.close();
  }
}
