import 'dart:async';

class AdHelper {
  static String audioInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/8976228547';
  static String topBannerAdUnitId = 'ca-app-pub-1335231177917759/5534372675';
  static String bottomBannerAdUnitId = 'ca-app-pub-1335231177917759/5361028570';
  static String gameBannerAdUnitId = 'ca-app-pub-1335231177917759/7891122756';
  static String audioBannerAdUnitId = 'ca-app-pub-1335231177917759/9799513488';
  static String articleInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/6100351403';

  static String chitChatInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/2875368361';

  static String ebookInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/8025343957';

  static String jackpotInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/2304166849';

  static String flipcardInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/6142505353';

  static String wordpuzzleInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/6216379745';

  static String imagepuzzleInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/9364507014';
  static String snakeladderInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/1976863780';
  static String shootInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/4829423689';
  static String feedmeInterstitialAdUnitId =
      'ca-app-pub-1335231177917759/6348295581';

  static const int interstitialAdInterval = 120;
  static const int rewardedAdInterval = 120;
  static const int maxAdRequestTimesPerHour = 20;

  static int interstitialAdRequestTimes = 0;

  static int interstitialAdCounter = 0;
  static Timer? interstitialAdTimer;
  static runInterstitialAdTimer() {
    interstitialAdTimer?.cancel();
    interstitialAdCounter = interstitialAdInterval;
    interstitialAdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (interstitialAdCounter == 0) {
        timer.cancel();
        interstitialAdTimer?.cancel();
      } else {
        interstitialAdCounter = interstitialAdCounter - 1;
      }
    });
  }
}
