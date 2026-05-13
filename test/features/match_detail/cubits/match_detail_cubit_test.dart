import 'package:app_copa_do_mundo/core/analytics/analytics_service.dart';
import 'package:app_copa_do_mundo/features/match_detail/domain/usecases/get_match_detail_use_case.dart';
import 'package:app_copa_do_mundo/features/match_detail/presentation/cubits/match_detail_cubit.dart';
import 'package:app_copa_do_mundo/features/match_detail/presentation/cubits/match_detail_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_fixtures.dart';

class _MockGetMatchDetailUseCase extends Mock implements GetMatchDetailUseCase {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late _MockGetMatchDetailUseCase mockUseCase;
  late _MockAnalyticsService mockAnalytics;

  setUp(() {
    mockUseCase = _MockGetMatchDetailUseCase();
    mockAnalytics = _MockAnalyticsService();
    when(() => mockAnalytics.logMatchViewed(any())).thenAnswer((_) async {});
    when(() => mockAnalytics.logH2HBlocked(any())).thenAnswer((_) async {});
  });

  MatchDetailCubit buildCubit() => MatchDetailCubit(mockUseCase, mockAnalytics);

  group('MatchDetailCubit', () {
    test('initial state is MatchDetailInitial', () {
      expect(buildCubit().state, isA<MatchDetailInitial>());
    });

    blocTest<MatchDetailCubit, MatchDetailState>(
      'emits [Loading, Loaded] when load succeeds with finished match',
      build: buildCubit,
      setUp: () {
        when(() => mockUseCase(1))
            .thenAnswer((_) async => TestFixtures.finishedMatchDetail(id: 1));
      },
      act: (cubit) => cubit.load(1),
      expect: () => [
        isA<MatchDetailLoading>(),
        isA<MatchDetailLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as MatchDetailLoaded;
        expect(state.detail.match.id, 1);
        expect(state.isPolling, isFalse);
        verify(() => mockAnalytics.logMatchViewed(1)).called(1);
      },
    );

    blocTest<MatchDetailCubit, MatchDetailState>(
      'emits [Loading, Error] when load throws',
      build: buildCubit,
      setUp: () {
        when(() => mockUseCase(1)).thenThrow(Exception('not found'));
      },
      act: (cubit) => cubit.load(1),
      expect: () => [isA<MatchDetailLoading>(), isA<MatchDetailError>()],
    );

    blocTest<MatchDetailCubit, MatchDetailState>(
      'emits [Loading, Loaded] with isPolling:false for live match (polling timer is separate)',
      build: buildCubit,
      setUp: () {
        when(() => mockUseCase(2))
            .thenAnswer((_) async => TestFixtures.liveMatchDetail(id: 2));
      },
      act: (cubit) => cubit.load(2),
      expect: () => [
        isA<MatchDetailLoading>(),
        isA<MatchDetailLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as MatchDetailLoaded;
        expect(state.detail.match.isLive, isTrue);
        verify(() => mockAnalytics.logMatchViewed(2)).called(1);
      },
    );

    blocTest<MatchDetailCubit, MatchDetailState>(
      'refresh updates state on success and keeps polling for live match',
      build: buildCubit,
      setUp: () {
        when(() => mockUseCase(1))
            .thenAnswer((_) async => TestFixtures.finishedMatchDetail(id: 1));
        when(() => mockUseCase.refresh(1))
            .thenAnswer((_) async => TestFixtures.liveMatchDetail(id: 1));
      },
      act: (cubit) async {
        await cubit.load(1);
        await cubit.refresh();
      },
      expect: () => [
        isA<MatchDetailLoading>(),
        isA<MatchDetailLoaded>(),
        isA<MatchDetailLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as MatchDetailLoaded;
        expect(state.detail.match.isLive, isTrue);
      },
    );

    blocTest<MatchDetailCubit, MatchDetailState>(
      'refresh is silent on failure — keeps last state',
      build: buildCubit,
      setUp: () {
        when(() => mockUseCase(1))
            .thenAnswer((_) async => TestFixtures.finishedMatchDetail(id: 1));
        when(() => mockUseCase.refresh(1)).thenThrow(Exception('network error'));
      },
      act: (cubit) async {
        await cubit.load(1);
        await cubit.refresh();
      },
      expect: () => [
        isA<MatchDetailLoading>(),
        isA<MatchDetailLoaded>(),
        // no additional state — refresh failure is silent
      ],
    );

    blocTest<MatchDetailCubit, MatchDetailState>(
      'logH2HBlocked calls analytics with current fixtureId',
      build: buildCubit,
      setUp: () {
        when(() => mockUseCase(1))
            .thenAnswer((_) async => TestFixtures.finishedMatchDetail(id: 1));
      },
      act: (cubit) async {
        await cubit.load(1);
        cubit.logH2HBlocked();
      },
      verify: (_) => verify(() => mockAnalytics.logH2HBlocked(1)).called(1),
    );

    blocTest<MatchDetailCubit, MatchDetailState>(
      'logH2HBlocked before load does nothing (no fixtureId)',
      build: buildCubit,
      act: (cubit) => cubit.logH2HBlocked(),
      verify: (_) => verifyNever(() => mockAnalytics.logH2HBlocked(any())),
    );
  });
}
