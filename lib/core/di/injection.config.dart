// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/home/data/repositories/fixtures_repository_impl.dart'
    as _i147;
import '../../features/home/domain/repositories/fixtures_repository.dart'
    as _i402;
import '../../features/home/domain/usecases/get_current_group_stage_matches_use_case.dart'
    as _i780;
import '../../features/home/domain/usecases/get_today_matches_use_case.dart'
    as _i35;
import '../../features/home/presentation/cubits/home_cubit.dart' as _i825;
import '../../features/match_detail/data/repositories/match_detail_repository_impl.dart'
    as _i611;
import '../../features/match_detail/domain/repositories/match_detail_repository.dart'
    as _i399;
import '../../features/match_detail/domain/usecases/get_match_detail_use_case.dart'
    as _i721;
import '../../features/match_detail/presentation/cubits/match_detail_cubit.dart'
    as _i830;
import '../../features/matches/data/repositories/group_matches_repository_impl.dart'
    as _i602;
import '../../features/matches/domain/repositories/group_matches_repository.dart'
    as _i1064;
import '../../features/matches/domain/usecases/get_grouped_matches_use_case.dart'
    as _i244;
import '../../features/matches/presentation/cubits/matches_cubit.dart' as _i374;
import '../../features/standings/data/repositories/standings_repository_impl.dart'
    as _i538;
import '../../features/standings/domain/repositories/standings_repository.dart'
    as _i1014;
import '../../features/standings/domain/usecases/get_standings_use_case.dart'
    as _i900;
import '../../features/standings/presentation/cubits/standings_cubit.dart'
    as _i979;
import '../../features/subscription/data/repositories/subscription_repository_impl.dart'
    as _i888;
import '../../features/subscription/domain/repositories/subscription_repository.dart'
    as _i777;
import '../../features/subscription/presentation/cubits/subscription_cubit.dart'
    as _i555;
import '../ads/interstitial_ad_controller.dart' as _i301;
import '../analytics/analytics_service.dart' as _i456;
import '../api/api_client.dart' as _i277;
import '../api/fixtures_datasource.dart' as _i425;
import '../api/match_detail_datasource.dart' as _i712;
import '../api/standings_datasource.dart' as _i588;
import '../cache/cache_manager.dart' as _i326;
import '../remote_config/remote_config_service.dart' as _i633;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i277.ApiClient>(() => _i277.ApiClient());
    await gh.lazySingletonAsync<_i326.CacheManager>(
      () => appModule.cacheManager,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i633.RemoteConfigService>(
      () => appModule.remoteConfigService,
      preResolve: true,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => appModule.firebaseFirestore,
    );
    gh.lazySingleton<_i301.InterstitialAdController>(
      () => _i301.InterstitialAdController(gh<_i633.RemoteConfigService>()),
    );
    gh.lazySingleton<_i456.AnalyticsService>(() => _i456.AnalyticsService());
    gh.lazySingleton<_i425.FixturesDataSource>(
      () => _i425.FixturesDataSource(gh<_i277.ApiClient>()),
    );
    gh.lazySingleton<_i588.StandingsDataSource>(
      () => _i588.StandingsDataSource(gh<_i277.ApiClient>()),
    );
    gh.lazySingleton<_i712.MatchDetailDataSource>(
      () => _i712.MatchDetailDataSource(gh<_i277.ApiClient>()),
    );
    gh.lazySingleton<_i402.FixturesRepository>(
      () => _i147.FixturesRepositoryImpl(
        gh<_i425.FixturesDataSource>(),
        gh<_i326.CacheManager>(),
      ),
    );
    gh.lazySingleton<_i1014.StandingsRepository>(
      () => _i538.StandingsRepositoryImpl(
        gh<_i588.StandingsDataSource>(),
        gh<_i326.CacheManager>(),
      ),
    );
    gh.lazySingleton<_i1064.GroupMatchesRepository>(
      () => _i602.GroupMatchesRepositoryImpl(
        gh<_i425.FixturesDataSource>(),
        gh<_i588.StandingsDataSource>(),
        gh<_i326.CacheManager>(),
      ),
    );
    gh.lazySingleton<_i399.MatchDetailRepository>(
      () => _i611.MatchDetailRepositoryImpl(
        gh<_i712.MatchDetailDataSource>(),
        gh<_i326.CacheManager>(),
      ),
    );
    gh.lazySingleton<_i777.SubscriptionRepository>(
      () => _i888.SubscriptionRepositoryImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i555.SubscriptionCubit>(
      () => _i555.SubscriptionCubit(
        gh<_i777.SubscriptionRepository>(),
        gh<_i456.AnalyticsService>(),
      ),
    );
    gh.factory<_i900.GetStandingsUseCase>(
      () => _i900.GetStandingsUseCase(gh<_i1014.StandingsRepository>()),
    );
    gh.factory<_i35.GetTodayMatchesUseCase>(
      () => _i35.GetTodayMatchesUseCase(gh<_i402.FixturesRepository>()),
    );
    gh.factory<_i780.GetCurrentGroupStageMatchesUseCase>(
      () => _i780.GetCurrentGroupStageMatchesUseCase(gh<_i402.FixturesRepository>()),
    );
    gh.factory<_i244.GetGroupedMatchesUseCase>(
      () => _i244.GetGroupedMatchesUseCase(gh<_i1064.GroupMatchesRepository>()),
    );
    gh.factory<_i721.GetMatchDetailUseCase>(
      () => _i721.GetMatchDetailUseCase(gh<_i399.MatchDetailRepository>()),
    );
    gh.factory<_i825.HomeCubit>(
      () => _i825.HomeCubit(gh<_i780.GetCurrentGroupStageMatchesUseCase>()),
    );
    gh.factory<_i374.MatchesCubit>(
      () => _i374.MatchesCubit(gh<_i244.GetGroupedMatchesUseCase>()),
    );
    gh.factory<_i979.StandingsCubit>(
      () => _i979.StandingsCubit(gh<_i900.GetStandingsUseCase>()),
    );
    gh.factory<_i830.MatchDetailCubit>(
      () => _i830.MatchDetailCubit(
        gh<_i721.GetMatchDetailUseCase>(),
        gh<_i456.AnalyticsService>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
