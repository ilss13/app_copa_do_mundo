import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../cache/cache_manager.dart';
import '../remote_config/remote_config_service.dart';

@module
abstract class AppModule {
  @preResolve
  @lazySingleton
  Future<CacheManager> get cacheManager async {
    final manager = CacheManager();
    await manager.init();
    return manager;
  }

  @preResolve
  @lazySingleton
  Future<RemoteConfigService> get remoteConfigService async {
    final service = RemoteConfigService();
    await service.init();
    return service;
  }

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;
}
