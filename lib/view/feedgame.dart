import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FeedGame extends StatefulWidget {
  const FeedGame({super.key});

  @override
  State<FeedGame> createState() => _FeedGameState();
}

class _FeedGameState extends State<FeedGame> {
  List<String> noenoeActions = [
    './lib/image/jackpot/noenoe/action_0.gif',
    './lib/image/jackpot/noenoe/action_1.gif',
    './lib/image/jackpot/noenoe/action_2.gif',
    './lib/image/jackpot/noenoe/action_3.gif',
    './lib/image/jackpot/noenoe/action_4.gif',
    './lib/image/jackpot/noenoe/action_5.gif',
    './lib/image/jackpot/noenoe/action_6.gif',
    './lib/image/jackpot/noenoe/action_7.gif',
    './lib/image/jackpot/noenoe/action_8.gif',
    './lib/image/jackpot/noenoe/action_9.gif',
  ];
  List<String> foodList = [
    './lib/image/jackpot/noenoe/food_0.gif',
    './lib/image/jackpot/noenoe/food_1.gif',
    './lib/image/jackpot/noenoe/food_2.gif',
    './lib/image/jackpot/noenoe/food_3.gif',
    './lib/image/jackpot/noenoe/food_4.gif',
    './lib/image/jackpot/noenoe/food_5.gif',
    './lib/image/jackpot/noenoe/food_6.gif',
    './lib/image/jackpot/noenoe/food_7.gif',
    './lib/image/jackpot/noenoe/food_8.gif',
    './lib/image/jackpot/noenoe/food_9.gif',
  ];

  List<Color> colors = [
    Colors.black,
    Colors.green,
    Colors.pink,
    Colors.yellow,
    Colors.blue,
  ];

  int colorIndex = 0;

  String gameState = "IDLE";
  int result = 0;
  String noenoeAction = './lib/image/jackpot/noenoe/NoeNoe.gif';
  String foodOne = './lib/image/jackpot/noenoe/plate.png';
  String foodTwo = './lib/image/jackpot/noenoe/plate.png';
  String foodThree = './lib/image/jackpot/noenoe/plate.png';
  String foodFour = './lib/image/jackpot/noenoe/plate.png';
  String foodFive = './lib/image/jackpot/noenoe/plate.png';

  AudioPlayer homePlayer = AudioPlayer();
  AudioPlayer ringPlayer = AudioPlayer();
  AudioPlayer happyPlayer = AudioPlayer();
  AudioPlayer angryPlayer = AudioPlayer();

  List<String> puzzlePlate = [
    './lib/image/jackpot/noenoe/empty.png',
    './lib/image/jackpot/noenoe/empty.png',
    './lib/image/jackpot/noenoe/empty.png',
    './lib/image/jackpot/noenoe/empty.png',
    './lib/image/jackpot/noenoe/empty.png',
  ];

  bool isLoading = false;
  bool selectTime = false;
  bool showResult = false;
  bool isHappy = false;

  playGame() {
    ringPlayer.play(AssetSource('feedring.mp3'));
    puzzlePlate = [];
    puzzlePlate = [
      './lib/image/jackpot/noenoe/empty.png',
      './lib/image/jackpot/noenoe/empty.png',
      './lib/image/jackpot/noenoe/empty.png',
      './lib/image/jackpot/noenoe/empty.png',
      './lib/image/jackpot/noenoe/empty.png',
    ];
    setState(() {
      isLoading = true;
      selectTime = false;
      showResult = false;
      foodOne = foodTwo = foodThree =
          foodFour = foodFive = './lib/image/jackpot/noenoe/plate.png';
      noenoeAction = './lib/image/jackpot/noenoe/NoeNoe.gif';
    });
    result = Random().nextInt(5);
    int counter = 14400;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (counter == 0) {
        timer.cancel();
        puzzlePlate[result] = foodList[Random().nextInt(9)];
        setState(() {
          isLoading = false;
          selectTime = true;
        });
        ringPlayer.stop();
      } else {
        counter = counter - 200;
        setState(() {
          colorIndex = Random().nextInt(5);
        });
      }
    });
  }

  checkResult(String food) {
    if (food == './lib/image/jackpot/noenoe/empty.png') {
      angryPlayer.play(AssetSource('angry.wav'));
      noenoeAction = noenoeActions[Random().nextInt(5)];
      isHappy = false;
      showResult = true;
      UserCredential.addFlipChance(-1);
    } else {
      happyPlayer.play(AssetSource('happy.wav'));
      noenoeAction = noenoeActions[Random().nextInt(5) + 5];
      isHappy = true;
      showResult = true;
      UserCredential.increaseJackpotTicket(1);
    }
  }

  Widget getGameCard() {
    switch (gameState) {
      case "PLAY":
        return playCard();
      default:
        return idleCard();
    }
  }

  BannerAd? bannerAd;
  bool isBannaAdLoaded = false;

  void loadAd() {
    bannerAd = BannerAd(
      adUnitId: AdHelper.gameBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isBannaAdLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  int adTimer = 0;
  InterstitialAd? interstitialAd;
  int adReloadTimes = 0;
  bool adReady = false;
  Timer? _adTimer;

  loadInterstatialAd() {
    if (AdHelper.interstitialAdRequestTimes >=
        AdHelper.maxAdRequestTimesPerHour) {
      return;
    } else {
      AdHelper.interstitialAdRequestTimes++;
      InterstitialAd.load(
        adUnitId: AdHelper.feedmeInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                interstitialAd?.dispose();
                setState(() {
                  adReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                reloadAd();
                playGame();
              },
              onAdShowedFullScreenContent: (ad) {
                UserCredential.increasePoint();
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                interstitialAd?.dispose();

                setState(() {
                  adReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                reloadAd();
                playGame();
              },
            );
            interstitialAd = ad;
            setState(() {
              adReady = true;
            });
            adReloadTimes = 0;
            AdHelper.interstitialAdTimer?.cancel();
          },
          onAdFailedToLoad: (error) {
            setState(() {
              adReady = false;
            });
            if (adReloadTimes < 3) {
              AdHelper.runInterstitialAdTimer();
              adReloadTimes++;
              reloadAd();
            }
          },
        ),
      );
    }
  }

  reloadAd() {
    _adTimer = Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
      loadInterstatialAd();
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
    homePlayer.play(AssetSource('noenoe_home.mp3'));
    loadInterstatialAd();
    WakelockPlus.enable();
    increasePoint();
    super.initState();
  }

  @override
  void dispose() {
    homePlayer.dispose();
    ringPlayer.dispose();
    happyPlayer.dispose();
    angryPlayer.dispose();
    bannerAd?.dispose();
    interstitialAd?.dispose();
    WakelockPlus.disable();
    _adTimer?.cancel();
    _pointTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: getGameCard(),
        bottomNavigationBar: isBannaAdLoaded
            ? SizedBox(
                width: double.infinity,
                height: bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: bannerAd!),
              )
            : const SizedBox(width: double.infinity, height: 50),
      ),
    );
  }

  Widget idleCard() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '"Noe Noe"',
            style: TextStyle(
              fontFamily: 'Motley Forces',
              color: Colors.pink,
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
          Container(
            width: 300,
            height: 150,
            alignment: Alignment.center,
            child: const Text(
              "Noe Noe want to have something. Let's choose the one he like.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Penguin Attack',
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          Image.asset(
            './lib/image/jackpot/noenoe/NoeNoe.gif',
            width: 100,
          ),
          GestureDetector(
            onTap: () {
              if (UserCredential.flipChance > 0) {
                homePlayer.stop();
                setState(() {
                  gameState = "PLAY";
                });
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: DesignProvider.getDialogBoxShape(10),
                    title: const Text("No chance"),
                    content: const Text(
                        "Sorry!, you have no more play chance. Please watch ads or use star."),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
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
              width: 150,
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'P L A Y',
                style: TextStyle(
                  fontFamily: 'Motley Forces',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          //---exit button ----
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 100,
              height: 40,
              margin: const EdgeInsets.only(bottom: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'E X I T',
                style: TextStyle(
                  fontFamily: 'Motley Forces',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          getChanceCard(),
        ],
      ),
    );
  }

  Widget playCard() {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            showResult
                ? Container(
                    width: 300,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    child: Text(
                      isHappy
                          ? "WOW.. It's so delicious.\nI'will give you 1 jackpot ticket."
                          : "OPP... NOoooo!!\nLet's try again.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Penguin Attack',
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                    ),
                  )
                : Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: const Text(
                      "Feed Me!! Feed Me!!!",
                      style: TextStyle(
                        fontFamily: 'Motley Forces',
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
            Container(
              width: 110,
              height: 110,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Image.asset(noenoeAction),
            ),

            // ---- Plate Card -----
            SizedBox(
              width: 270,
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // --- Plate One ---
                  GestureDetector(
                    onTap: () {
                      if (selectTime) {
                        setState(() {
                          selectTime = false;
                          foodOne = puzzlePlate[0];
                          checkResult(foodOne);
                        });
                      }
                    },
                    child: plateCard(foodOne),
                  ),

                  // --- Plate Two ---
                  GestureDetector(
                    onTap: () {
                      if (selectTime) {
                        setState(() {
                          selectTime = false;
                          foodTwo = puzzlePlate[1];
                          checkResult(foodTwo);
                        });
                      }
                    },
                    child: plateCard(foodTwo),
                  ),

                  // --- Plate Three ---
                  GestureDetector(
                    onTap: () {
                      if (selectTime) {
                        setState(() {
                          selectTime = false;
                          foodThree = puzzlePlate[2];
                          checkResult(foodThree);
                        });
                      }
                    },
                    child: plateCard(foodThree),
                  ),
                ],
              ),
            ),

            // ---- Plate Card 2 ----
            SizedBox(
              width: 180,
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // --- Plate Four ---
                  GestureDetector(
                    onTap: () {
                      if (selectTime) {
                        setState(() {
                          selectTime = false;

                          foodFour = puzzlePlate[3];
                          checkResult(foodFour);
                        });
                      }
                    },
                    child: plateCard(foodFour),
                  ),

                  // --- Plate Five ---
                  GestureDetector(
                    onTap: () {
                      if (selectTime) {
                        setState(() {
                          selectTime = false;
                          foodFive = puzzlePlate[4];
                          checkResult(foodFive);
                        });
                      }
                    },
                    child: plateCard(foodFive),
                  ),
                ],
              ),
            ),

            // --- Show select letter ---
            Text(
              selectTime ? "PLEASE CHOOSE ONE FOR NOE NOE!!" : "",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            // --- start button ----
            GestureDetector(
              onTap: () {
                if (!isLoading && !selectTime) {
                  if (UserCredential.flipChance > 0) {
                    playGame();
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: DesignProvider.getDialogBoxShape(10),
                        title: const Text('No chance!'),
                        content: const Text(
                            'Sorry you have no more play chance. Please watch ads or use star.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: 150,
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isLoading
                      ? 'Loading...'
                      : selectTime
                          ? 'S E L E C T'
                          : 'S T A R T',
                  style: const TextStyle(
                    fontFamily: 'Motley Forces',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            // --- exit button ----
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 110,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'E X I T',
                  style: TextStyle(
                    fontFamily: 'Motley Forces',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            getChanceCard(),
          ],
        ),
      ),
    );
  }

  Widget plateCard(String food) {
    return Container(
      width: 70,
      height: 60,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(4),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        border: Border.all(
          color: colors[colorIndex],
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(food),
    );
  }

  Widget getChanceCard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text(
            "You have ${UserCredential.flipChance} play chance(s).",
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 6.0),
          child: Text(
            "If you don't have play chance:",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (adReady) {
                  interstitialAd?.show();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: DesignProvider.getDialogBoxShape(10),
                      title: const Text('No Ads'),
                      content: const Text(
                          'Sorry! Ads is not ready. Please try again later.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (adReloadTimes < 3) {
                              reloadAd();
                            }
                          },
                          child: const Text('OK'),
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
                if (UserCredential.userProfile.remainedPoints < 2) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: DesignProvider.getDialogBoxShape(10),
                      title: const Text('No stars!'),
                      content: const Text('Sorry! You have no enough stars.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (adReloadTimes < 3) {
                              reloadAd();
                            }
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  Fluttertoast.showToast(msg: '5 play chance added.');
                  UserCredential.deductPoints(1);
                  setState(() {
                    UserCredential.addFlipChance(5);
                  });
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
                    const Text('Use a star'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
