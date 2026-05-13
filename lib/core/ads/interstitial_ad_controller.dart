import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../remote_config/remote_config_service.dart';

class InterstitialAdController {
  InterstitialAdController(this._remoteConfig);

  final RemoteConfigService _remoteConfig;
  InterstitialAd? _ad;
  int _navCount = 0;

  void init() => _preload();

  void onNavigated() {
    _navCount++;
    if (_navCount >= _remoteConfig.interstitialThreshold) {
      _navCount = 0;
      _showIfReady();
    }
  }

  void _preload() {
    InterstitialAd.load(
      adUnitId: _remoteConfig.interstitialAdUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _ad = ad,
        onAdFailedToLoad: (_) => _ad = null,
      ),
    );
  }

  void _showIfReady() {
    final ad = _ad;
    if (ad == null) {
      _preload();
      return;
    }
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _preload();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _preload();
      },
    );
    ad.show();
  }

  void dispose() => _ad?.dispose();
}
