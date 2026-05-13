import 'package:app_copa_do_mundo/core/api/api_exception.dart';
import 'package:app_copa_do_mundo/features/standings/domain/usecases/get_standings_use_case.dart';
import 'package:app_copa_do_mundo/features/standings/presentation/cubits/standings_cubit.dart';
import 'package:app_copa_do_mundo/features/standings/presentation/cubits/standings_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_fixtures.dart';

class _MockGetStandingsUseCase extends Mock implements GetStandingsUseCase {}

void main() {
  late _MockGetStandingsUseCase mockUseCase;

  setUp(() {
    mockUseCase = _MockGetStandingsUseCase();
  });

  group('StandingsCubit', () {
    test('initial state is StandingsInitial', () {
      when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => {});
      expect(StandingsCubit(mockUseCase).state, isA<StandingsInitial>());
    });

    blocTest<StandingsCubit, StandingsState>(
      'emits [Loading, Loaded] with grouped standings',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => TestFixtures.groupedStandings());
        return StandingsCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<StandingsLoading>(), isA<StandingsLoaded>()],
      verify: (cubit) {
        final state = cubit.state as StandingsLoaded;
        expect(state.groups, containsAll(['Group A', 'Group B']));
        expect(state.grouped['Group A']!.length, 2);
      },
    );

    blocTest<StandingsCubit, StandingsState>(
      'emits [Loading, Error] when ApiException is thrown',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(const ServerException('Internal Server Error', 500));
        return StandingsCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<StandingsLoading>(), isA<StandingsError>()],
      verify: (cubit) {
        final state = cubit.state as StandingsError;
        expect(state.message, 'Internal Server Error');
      },
    );

    blocTest<StandingsCubit, StandingsState>(
      'emits [Loading, Error] on generic exception',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(Exception('fail'));
        return StandingsCubit(mockUseCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<StandingsLoading>(), isA<StandingsError>()],
    );

    blocTest<StandingsCubit, StandingsState>(
      'refresh calls load with forceRefresh: true',
      build: () {
        when(() => mockUseCase(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => {});
        return StandingsCubit(mockUseCase);
      },
      act: (cubit) => cubit.refresh(),
      verify: (_) => verify(
        () => mockUseCase(forceRefresh: true),
      ).called(1),
    );
  });
}
