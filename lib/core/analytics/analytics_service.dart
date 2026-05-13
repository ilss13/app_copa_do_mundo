import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AnalyticsService {
  final _analytics = FirebaseAnalytics.instance;

  Future<void> logMatchViewed(int matchId) => _analytics.logEvent(
        name: 'match_viewed',
        parameters: {'match_id': matchId},
      );

  Future<void> logSubscriptionStarted(String productId) => _analytics.logEvent(
        name: 'subscription_started',
        parameters: {'product_id': productId},
      );

  Future<void> logSubscriptionConverted(String productId) => _analytics.logEvent(
        name: 'subscription_converted',
        parameters: {'product_id': productId},
      );

  Future<void> logH2HBlocked(int matchId) => _analytics.logEvent(
        name: 'h2h_blocked',
        parameters: {'match_id': matchId},
      );
}
