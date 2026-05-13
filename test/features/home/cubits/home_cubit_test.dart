import 'package:app_copa_do_mundo/core/api/api_exception.dart';
import 'package:app_copa_do_mundo/features/home/domain/usecases/get_today_matches_use_case.dart';
import 'package:app_copa_do_mundo/features/home/presentation/cubits/home_cubit.dart';
import 'package:app_copa_do_mundo/features/home/presentation/cubits/home_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_fixtures.dart';

class _MockGetTodayMatchesUseCase extends Mock implements GetTodayMatchesUseCase {}

void main() {
  late _MockGetTodayMatchesUseCase mockUseCase;

  setUp(() {
    mockUseCase = _MockGetTodayMatchesUseCase();
  });

  group('HomeCubit', () {
    test('initial state is HomeInitial', () {
      when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => []);
      expect(HomeCubit(mockUseCase).state, isA<HomeInitial>());
    });

    blocTest<HomeCubit, HomeState>(
      'emits [Loading, Loaded] when matches are returned',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [TestFixtures.finishedMatch()]);
        return HomeCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HomeLoaded;
        expect(state.matches.length, 1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits [Loading, Empty] when use case returns empty list',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => []);
        return HomeCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<HomeLoading>(), isA<HomeEmpty>()],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [Loading, Error] when ApiException is thrown',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(const NetworkException());
        return HomeCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HomeError;
        expect(state.message, 'Sem conexão com a internet. Verifique sua rede.');
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits [Loading, Error] when unexpected exception is thrown',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(Exception('unknown'));
        return HomeCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<HomeLoading>(), isA<HomeError>()],
    );

    blocTest<HomeCubit, HomeState>(
      'refresh calls load with forceRefresh: true',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [TestFixtures.finishedMatch()]);
        return HomeCubit(mockUseCase);
      },
      act: (cubit) => cubit.refresh(),
      verify: (_) => verify(
        () => mockUseCase(forceRefresh: true),
      ).called(1),
    );

    test('HomeLoaded partitions matches by status', () {
      final matches = [
        TestFixtures.liveMatch(),
        TestFixtures.upcomingMatch(),
        TestFixtures.finishedMatch(),
      ];
      final state = HomeLoaded(matches);
      expect(state.liveMatches.length, 1);
      expect(state.upcomingMatches.length, 1);
      expect(state.finishedMatches.length, 1);
    });
  });
}
