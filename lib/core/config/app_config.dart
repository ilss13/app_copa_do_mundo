abstract final class AppConfig {
  static const apiBaseUrl = 'https://v3.football.api-sports.io';
  static const apiKey = String.fromEnvironment('API_FOOTBALL_KEY', defaultValue: '');

  // World Cup 2026 league ID on API Football
  static const worldCupLeagueId = 1;
  static const worldCupSeason = 2026;

  // Cache TTLs em segundos
  static const cacheTtlTodayMatches = 300;    // 5 min
  static const cacheTtlAllMatches = 1800;     // 30 min
  static const cacheTtlStandings = 1800;      // 30 min
  static const cacheTtlLineups = 3600;        // 1h
  static const cacheTtlStatisticsFinished = 3600; // 1h
  static const cacheTtlH2h = 86400;           // 24h

  // Polling intervals em segundos
  static const pollingLiveMatch = 30;
  static const pollingTodayMatches = 60;

  // Remote Config chaves
  static const rcInterstitialThreshold = 'interstitial_page_threshold';
  static const rcBannerAdUnitAndroid = 'banner_ad_unit_android';
  static const rcBannerAdUnitIos = 'banner_ad_unit_ios';
  static const rcInterstitialAdUnitAndroid = 'interstitial_ad_unit_android';
  static const rcInterstitialAdUnitIos = 'interstitial_ad_unit_ios';

  // AdMob Test IDs
  static const testBannerAdUnitAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const testBannerAdUnitIos = 'ca-app-pub-3940256099942544/2934735716';
  static const testInterstitialAdUnitAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const testInterstitialAdUnitIos = 'ca-app-pub-3940256099942544/4411468910';
}
