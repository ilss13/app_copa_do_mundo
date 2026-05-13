import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/cache/cache_manager.dart';
import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
  ));

  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa CacheManager e registra manualmente antes do DI
  final cacheManager = CacheManager();
  await cacheManager.init();
  GetIt.instance.registerSingleton<CacheManager>(cacheManager);

  await configureDependencies();

  runApp(const AppCopaDeMundo());
}

class AppCopaDeMundo extends StatelessWidget {
  const AppCopaDeMundo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Copa do Mundo 2026',
      theme: AppTheme.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
