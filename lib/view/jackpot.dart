import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/profile.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/prizewinner.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class JackPot extends StatefulWidget {
  const JackPot({super.key});

  @override
  State<JackPot> createState() => _JackPotState();
}

class _JackPotState extends State<JackPot> {
  int cardOne = 4;
  int cardTwo = 4;
  int cardThree = 4;
  Timer? _timer;
  bool isSpring = false;
  bool win = false;
  bool buyTicket = false;
  String message = "Let's go!!";
  int ticketNumber = 0;
  int maxTicketNumber = UserCredential.userProfile.remainedPoints ~/ 5;

  AudioPlayer player = AudioPlayer();
  AudioPlayer endPlayer = AudioPlayer();

  startSpring() {
    player.play(AssetSource('ring.mp3'));
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        cardOne = Random().nextInt(14);
        cardTwo = Random().nextInt(14);
        cardThree = Random().nextInt(14);
      });
    });
    Timer(const Duration(seconds: 20), () {
      _timer?.cancel();
      player.stop();
      if (cardOne == cardTwo && cardTwo == cardThree) {
        endPlayer.play(AssetSource('Clap.mp3'));
        message = "YOU WIN THE PRIZE";
        win = true;
        Timer(const Duration(seconds: 2), () {
          if (cardOne == 4) {
            UserCredential.userProfile.prize =
                UserCredential.userProfile.prize + 1000;
          } else {
            UserCredential.userProfile.prize =
                UserCredential.userProfile.prize + 500;
          }
          API().editPrize();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrizeWinner(
                  prize: cardOne,
                ),
              ));
        });
      } else {
        endPlayer.play(AssetSource('lose.wav'));
        message = "TRY AGAIN";
        win = false;
      }

      setState(() {
        isSpring = false;
        message;
        win;
      });
    });
  }

  BannerAd? bannerAd;
  bool isBannaAdLoaded = false;

  void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: AdHelper.gameBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannaAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  InterstitialAd? _interstitialAd;
  bool adReady = false;
  int adRequestTimes = 0;

  void loadInterstitialAd() {
    if (AdHelper.interstitialAdRequestTimes >=
        AdHelper.maxAdRequestTimesPerHour) {
      return;
    } else {
      AdHelper.interstitialAdRequestTimes++;
      InterstitialAd.load(
        adUnitId: AdHelper.jackpotInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  UserCredential.increaseJackpotTicket(1);
                  UserCredential.increasePoint();
                },
                onAdImpression: (ad) {},
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                  _interstitialAd?.dispose();
                  setState(() {
                    adReady = false;
                  });
                  AdHelper.runInterstitialAdTimer();
                  startAdTimer();
                },
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _interstitialAd?.dispose();
                  setState(() {
                    adReady = false;
                  });
                  AdHelper.runInterstitialAdTimer();
                  startAdTimer();
                },
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');

            _interstitialAd = ad;
            adRequestTimes = 0;
            AdHelper.interstitialAdTimer?.cancel();
            setState(() {
              adReady = true;
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
            setState(() {
              adReady = false;
            });
            if (adRequestTimes < 3) {
              adRequestTimes++;
              AdHelper.runInterstitialAdTimer();
              startAdTimer();
            }
          },
        ),
      );
    }
  }

  Timer? _adTimer;
  startAdTimer() {
    _adTimer?.cancel();
    if (adReady) return;
    _adTimer = Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
      loadInterstitialAd();
    });
  }

  Timer? _pointTimer;
  increasePoint() {
    _pointTimer = Timer(const Duration(minutes: 1), () {
      UserCredential.increasePoint();
      setState(() {});
    });
  }

  @override
  void initState() {
    loadBannerAd();
    loadInterstitialAd();
    WakelockPlus.enable();
    increasePoint();
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    endPlayer.dispose();
    _timer?.cancel();
    _pointTimer?.cancel();
    _adTimer?.cancel();
    bannerAd?.dispose();
    _interstitialAd?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: const Alignment(1, -1),
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 130,
                    child: Image.asset('./lib/image/jackpot/jackpot.png'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        './lib/image/jackpot/exit_2.png',
                        width: 40,
                      ),
                    ),
                  )
                ],
              ),
              Container(
                width: double.infinity,
                height: 30,
                alignment: Alignment.center,
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    FadeAnimatedText(
                      'Welcome to Jackpot',
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    FadeAnimatedText(
                      "Let's play.",
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    FadeAnimatedText(
                      'You can win phone bill.',
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 300,
                height: 50,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('./lib/image/jackpot/border_2.png'),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 320,
                height: 110,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('./lib/image/jackpot/border.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('./lib/image/jackpot/$cardOne.png'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('./lib/image/jackpot/$cardTwo.png'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            Image.asset('./lib/image/jackpot/$cardThree.png'),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!isSpring) {
                    if (UserCredential.userProfile.jackpotTicket > 0) {
                      UserCredential.decreaseJackpotTicket(1);
                      setState(() {
                        isSpring = true;
                        message = "IT'S SPINING";
                      });
                      startSpring();
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: DesignProvider.getDialogBoxShape(10),
                          title: const Text('No ticket!!'),
                          content: const Text(
                              'Sorry!! You have no enough ticket. Watch Ads or buy ticket to play jackpot.'),
                          actions: [
                            ElevatedButton(
                              style: DesignProvider.getElevationButtonShape(
                                5,
                                Colors.red,
                                Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  height: 60,
                  width: 150,
                  margin: const EdgeInsets.only(bottom: 20),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('./lib/image/jackpot/button.png'),
                    ),
                  ),
                  child: Text(
                    isSpring ? "S P I N I N G" : 'S P I N',
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Container(
                width: 300,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 2),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(),
                    bottom: BorderSide(),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('You have: '),
                    Text(" ${UserCredential.userProfile.jackpotTicket} "),
                    const Icon(EneftyIcons.ticket_star_outline),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: Text(
                  "If you don't have ticket:",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (adReady) {
                        _interstitialAd?.show();
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: DesignProvider.getDialogBoxShape(10),
                            title: const Text("No Ads"),
                            content: const Text('Ads not ready. Try later!'),
                            actions: [
                              ElevatedButton(
                                style: DesignProvider.getElevationButtonShape(
                                  5,
                                  Colors.red,
                                  Colors.white,
                                ),
                                onPressed: () {
                                  startAdTimer();
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('./lib/image/jackpot/watch_ad.png'),
                          const Text('Watch ad'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text('|'),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!adReady) {
                        if (adRequestTimes < 3) startAdTimer();
                      }
                      if (UserCredential.userProfile.remainedPoints >= 5) {
                        setState(() {
                          buyTicket = true;
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: DesignProvider.getDialogBoxShape(10),
                            title: const Text('No Stars!!'),
                            content: const Text(
                                'Sorry!! You have no enough stars to buy ticket.'),
                            actions: [
                              ElevatedButton(
                                style: DesignProvider.getElevationButtonShape(
                                  5,
                                  Colors.red,
                                  Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              )
                            ],
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('./lib/image/jackpot/star.png'),
                          const Text('Use 2 stars'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                alignment: Alignment.center,
                child: const Text(
                  '🏆 Top 10 Prize Winner List 🏆',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    List<Profile> topList = UserCredential.profiles;
                    topList.sort(
                      (a, b) => a.prize.compareTo(b.prize),
                    );
                    topList = topList.reversed.toList();
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 1,
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text('${index + 1}'),
                          ),
                          Expanded(
                            child: Text(topList[index].userName),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text('${topList[index].prize}'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              isBannaAdLoaded
                  ? Container(
                      color: Theme.of(context).colorScheme.background,
                      width: bannerAd!.size.width.toDouble(),
                      height: bannerAd!.size.height.toDouble(),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: AdWidget(ad: bannerAd!),
                    )
                  : const SizedBox(height: 50),
            ],
          ),
          buyTicket
              ? Container(
                  color: Theme.of(context).colorScheme.background,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Buy Jackpot Ticket',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Icon(
                        EneftyIcons.ticket_star_outline,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Text('Select the number of tickets:'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (ticketNumber > 0) {
                                setState(() {
                                  ticketNumber = ticketNumber - 1;
                                });
                              }
                            },
                            icon: const Icon(EneftyIcons.minus_square_outline),
                          ),
                          Container(
                            width: 50,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Text('$ticketNumber'),
                          ),
                          IconButton(
                            onPressed: () {
                              if (ticketNumber < maxTicketNumber) {
                                setState(() {
                                  ticketNumber = ticketNumber + 1;
                                });
                              }
                            },
                            icon: const Icon(EneftyIcons.add_square_outline),
                          ),
                        ],
                      ),
                      Text('It will cost: ${ticketNumber * 5} stars.'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  buyTicket = false;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                if (ticketNumber > 0) {
                                  UserCredential.increaseJackpotTicket(
                                      ticketNumber);
                                  UserCredential.deductPoints(ticketNumber * 5);
                                  setState(() {
                                    buyTicket = false;
                                  });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape:
                                          DesignProvider.getDialogBoxShape(10),
                                      title: const Text('Ticket'),
                                      content: const Text(
                                          'Please select the number of tickets.'),
                                      actions: [
                                        ElevatedButton(
                                          style: DesignProvider
                                              .getElevationButtonShape(
                                            5,
                                            Colors.red,
                                            Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: const Text('Buy'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
