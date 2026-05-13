import 'dart:async';

import 'package:app_copa_do_mundo/core/analytics/analytics_service.dart';
import 'package:app_copa_do_mundo/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:app_copa_do_mundo/features/subscription/presentation/cubits/subscription_cubit.dart';
import 'package:app_copa_do_mundo/features/subscription/presentation/cubits/subscription_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _FakeProductDetails extends Fake implements ProductDetails {}

class _MockProductDetails extends Mock implements ProductDetails {
  @override
  String get id => 'premium_monthly';

  @override
  String get price => 'R\$ 9,90';

  @override
  String get title => 'Premium Mensal';

  @override
  String get description => 'Acesso premium por 1 mês';

  @override
  String get currencyCode => 'BRL';

  @override
  double get rawPrice => 9.90;

  @override
  String get currencySymbol => 'R\$';
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeProductDetails()));

  late _MockSubscriptionRepository mockRepo;
  late _MockAnalyticsService mockAnalytics;
  late _MockProductDetails mockProduct;
  late StreamController<bool> premiumController;

  setUp(() {
    mockRepo = _MockSubscriptionRepository();
    mockAnalytics = _MockAnalyticsService();
    mockProduct = _MockProductDetails();
    premiumController = StreamController<bool>.broadcast();

    when(() => mockRepo.premiumStatusStream)
        .thenAnswer((_) => premiumController.stream);
    when(() => mockAnalytics.logSubscriptionStarted(any()))
        .thenAnswer((_) async {});
    when(() => mockAnalytics.logSubscriptionConverted(any()))
        .thenAnswer((_) async {});
  });

  tearDown(() => premiumController.close());

  SubscriptionCubit buildCubit() => SubscriptionCubit(mockRepo, mockAnalytics);

  group('SubscriptionCubit', () {
    // ---------- Init behaviour (state-sequence testable, no concurrent act) ----

    blocTest<SubscriptionCubit, SubscriptionState>(
      'settles to idle with isPremium:false for free user on init',
      build: () {
        when(() => mockRepo.checkPremiumStatus()).thenAnswer((_) async => false);
        when(() => mockRepo.getProducts()).thenAnswer((_) async => []);
        return buildCubit();
      },
      wait: const Duration(milliseconds: 50),
      verify: (cubit) {
        expect(cubit.state.status, SubscriptionStatus.idle);
        expect(cubit.state.isPremium, isFalse);
      },
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'settles to idle with isPremium:true for premium user on init',
      build: () {
        when(() => mockRepo.checkPremiumStatus()).thenAnswer((_) async => true);
        when(() => mockRepo.getProducts()).thenAnswer((_) async => []);
        return buildCubit();
      },
      wait: const Duration(milliseconds: 50),
      verify: (cubit) {
        expect(cubit.state.status, SubscriptionStatus.idle);
        expect(cubit.state.isPremium, isTrue);
      },
    );

    // ---------- Purchase -------------------------------------------------------

    blocTest<SubscriptionCubit, SubscriptionState>(
      'purchase: calls repo and logs subscription_started',
      build: () {
        when(() => mockRepo.checkPremiumStatus()).thenAnswer((_) async => false);
        when(() => mockRepo.getProducts()).thenAnswer((_) async => []);
        when(() => mockRepo.purchase(any())).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.purchase(mockProduct),
      wait: const Duration(milliseconds: 50),
      verify: (cubit) {
        verify(() => mockRepo.purchase(mockProduct)).called(1);
        verify(() => mockAnalytics.logSubscriptionStarted('premium_monthly'))
            .called(1);
      },
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'purchase: emits error state and clears pendingProductId on exception',
      build: () {
        when(() => mockRepo.checkPremiumStatus()).thenAnswer((_) async => false);
        when(() => mockRepo.getProducts()).thenAnswer((_) async => []);
        when(() => mockRepo.purchase(any()))
            .thenThrow(Exception('payment failed'));
        return buildCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await cubit.purchase(mockProduct);
      },
      wait: const Duration(milliseconds: 20),
      verify: (cubit) {
        expect(cubit.state.status, SubscriptionStatus.error);
        expect(cubit.state.errorMessage, isNotNull);
      },
    );

    // ---------- Restore --------------------------------------------------------

    blocTest<SubscriptionCubit, SubscriptionState>(
      'restorePurchases: calls repo',
      build: () {
        when(() => mockRepo.checkPremiumStatus()).thenAnswer((_) async => false);
        when(() => mockRepo.getProducts()).thenAnswer((_) async => []);
        when(() => mockRepo.restorePurchases()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.restorePurchases(),
      wait: const Duration(milliseconds: 50),
      verify: (_) => verify(() => mockRepo.restorePurchases()).called(1),
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'restorePurchases: emits error on exception',
      build: () {
        when(() => mockRepo.checkPremiumStatus()).thenAnswer((_) async => false);
        when(() => mockRepo.getProducts()).thenAnswer((_) async => []);
        when(() => mockRepo.restorePurchases())
            .thenThrow(Exception('network error'));
        return buildCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await cubit.restorePurchases();
      },
      wait: const Duration(milliseconds: 20),
      verify: (cubit) {
        expect(cubit.state.status, SubscriptionStatus.error);
        expect(cubit.state.errorMessage, isNotNull);
      },
    );

    // ---------- Premium stream -------------------------------------------------

    blocTest<SubscriptionCubit, SubscriptionState>(
      'premiumStatusStream: state becomes isPremium:true when stream fires',
      build: () {
        when(() => mockRepo.checkPremiumStatus()).thenAnswer((_) async => false);
        when(() => mockRepo.getProducts()).thenAnswer((_) async => []);
        return buildCubit();
      },
      act: (cubit) async {
        // Let init complete so isPremium starts as false
        await Future<void>.delayed(const Duration(milliseconds: 20));
        premiumController.add(true);
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.isPremium, isTrue),
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'purchase then stream: logs subscription_converted with product id',
      build: () {
        when(() => mockRepo.checkPremiumStatus()).thenAnswer((_) async => false);
        when(() => mockRepo.getProducts()).thenAnswer((_) async => []);
        when(() => mockRepo.purchase(any())).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.purchase(mockProduct);
        premiumController.add(true);
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      wait: const Duration(milliseconds: 10),
      verify: (_) {
        verify(() =>
                mockAnalytics.logSubscriptionConverted('premium_monthly'))
            .called(1);
      },
    );

    // ---------- Getter ---------------------------------------------------------

    test('isPremium getter returns false before init completes', () async {
      when(() => mockRepo.checkPremiumStatus()).thenAnswer((_) async => false);
      when(() => mockRepo.getProducts()).thenAnswer((_) async => []);
      final cubit = buildCubit();
      expect(cubit.isPremium, isFalse);
      await cubit.close();
    });
  });
}
