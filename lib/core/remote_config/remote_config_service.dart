import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class RemoteConfigService {
  late final FirebaseRemoteConfig _rc;

  Future<void> init() async {
    _rc = FirebaseRemoteConfig.instance;
    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval:
          kDebugMode ? Duration.zero : const Duration(hours: 1),
    ));
    await _rc.setDefaults({
      AppConfig.rcInterstitialThreshold: 5,
      AppConfig.rcBannerAdUnitAndroid: AppConfig.testBannerAdUnitAndroid,
      AppConfig.rcBannerAdUnitIos: AppConfig.testBannerAdUnitIos,
      AppConfig.rcInterstitialAdUnitAndroid:
          AppConfig.testInterstitialAdUnitAndroid,
      AppConfig.rcInterstitialAdUnitIos: AppConfig.testInterstitialAdUnitIos,
    });
    try {
      await _rc.fetchAndActivate();
    } catch (_) {
      // defaults remain active if fetch fails
    }
  }

  int get interstitialThreshold =>
      _rc.getInt(AppConfig.rcInterstitialThreshold);

  String get bannerAdUnit {
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? AppConfig.testBannerAdUnitIos
          : AppConfig.testBannerAdUnitAndroid;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _rc.getString(AppConfig.rcBannerAdUnitIos)
        : _rc.getString(AppConfig.rcBannerAdUnitAndroid);
  }

  String get interstitialAdUnit {
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? AppConfig.testInterstitialAdUnitIos
          : AppConfig.testInterstitialAdUnitAndroid;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _rc.getString(AppConfig.rcInterstitialAdUnitIos)
        : _rc.getString(AppConfig.rcInterstitialAdUnitAndroid);
  }
}
