import 'package:app_copa_do_mundo/core/api/api_exception.dart';
import 'package:app_copa_do_mundo/features/matches/domain/usecases/get_grouped_matches_use_case.dart';
import 'package:app_copa_do_mundo/features/matches/presentation/cubits/matches_cubit.dart';
import 'package:app_copa_do_mundo/features/matches/presentation/cubits/matches_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_fixtures.dart';

class _MockGetGroupedMatchesUseCase extends Mock implements GetGroupedMatchesUseCase {}

void main() {
  late _MockGetGroupedMatchesUseCase mockUseCase;

  setUp(() {
    mockUseCase = _MockGetGroupedMatchesUseCase();
  });

  group('MatchesCubit', () {
    test('initial state is MatchesInitial', () {
      when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => {});
      expect(MatchesCubit(mockUseCase).state, isA<MatchesInitial>());
    });

    blocTest<MatchesCubit, MatchesState>(
      'emits [Loading, Loaded] with grouped matches',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => TestFixtures.groupedMatches());
        return MatchesCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<MatchesLoading>(), isA<MatchesLoaded>()],
      verify: (cubit) {
        final state = cubit.state as MatchesLoaded;
        expect(state.groups, containsAll(['Group A', 'Group B']));
        expect(state.grouped['Group A']!.length, 2);
      },
    );

    blocTest<MatchesCubit, MatchesState>(
      'emits [Loading, Error] when ApiException is thrown',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(const TimeoutException());
        return MatchesCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<MatchesLoading>(), isA<MatchesError>()],
      verify: (cubit) {
        final state = cubit.state as MatchesError;
        expect(state.message, 'A requisição demorou muito. Tente novamente.');
      },
    );

    blocTest<MatchesCubit, MatchesState>(
      'emits [Loading, Error] on generic exception',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(Exception('fail'));
        return MatchesCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<MatchesLoading>(), isA<MatchesError>()],
    );

    blocTest<MatchesCubit, MatchesState>(
      'refresh calls load with forceRefresh: true',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => {});
        return MatchesCubit(mockUseCase);
      },
      act: (cubit) => cubit.refresh(),
      verify: (_) => verify(
        () => mockUseCase(forceRefresh: true),
      ).called(1),
    );
  });
}
