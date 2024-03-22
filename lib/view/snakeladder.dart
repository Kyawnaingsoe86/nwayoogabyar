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

class SnakeLadderGame extends StatefulWidget {
  const SnakeLadderGame({super.key});

  @override
  State<SnakeLadderGame> createState() => _SnakeLadderGameState();
}

class _SnakeLadderGameState extends State<SnakeLadderGame> {
  List<int> paths = [
    36,
    35,
    34,
    33,
    32,
    31,
    25,
    26,
    27,
    28,
    29,
    30,
    24,
    23,
    22,
    21,
    20,
    19,
    13,
    14,
    15,
    16,
    17,
    18,
    12,
    11,
    10,
    9,
    8,
    7,
    1,
    2,
    3,
    4,
    5,
    6,
  ];

  List<String> dice = [
    "./lib/image/jackpot/dice_1.png",
    "./lib/image/jackpot/dice_2.png",
    "./lib/image/jackpot/dice_3.png",
    "./lib/image/jackpot/dice_4.png",
    "./lib/image/jackpot/dice_5.png",
    "./lib/image/jackpot/dice_6.png",
  ];

  int currentPosition = 1;
  int positionIndex = 30;
  int diceIndex = 0;
  int rollChance = 10;
  Timer? _timer;
  Timer? _rollTimer;
  bool isRolling = false;
  String gameState = 'IDEL';
  bool showGaveOver = false;

  resetGame() {
    setState(() {
      currentPosition = 1;
      positionIndex = 30;
      diceIndex = 0;
      rollChance = 10;
      isRolling = false;
    });
  }

  movePosition(int steps) {
    stepPlayer.play(AssetSource('footsteps.mp3'));
    int move = 0;
    int tempPosition = -1;
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (move < steps) {
        move++;
        currentPosition = currentPosition + 1;
        if (currentPosition > 36) {
          tempPosition = 36 - (currentPosition - 36);
          setState(() {
            positionIndex = paths.indexOf(tempPosition);
          });
        } else {
          setState(() {
            positionIndex = paths.indexOf(currentPosition);
          });
        }
      } else {
        stepPlayer.stop();
        timer.cancel();
        if (tempPosition > -1) {
          setState(() {
            currentPosition = tempPosition;
          });
        }
        if (currentPosition == 6) {
          ladderPlayer.play(AssetSource('ladder.mp3'));
          Timer(const Duration(seconds: 1), () {
            setState(() {
              currentPosition = 18;
              positionIndex = paths.indexOf(currentPosition);
            });
          });
        } else if (currentPosition == 10) {
          snakePlayer.play(AssetSource('snake.mp3'));
          Timer(const Duration(seconds: 1), () {
            setState(() {
              currentPosition = 4;
              positionIndex = paths.indexOf(currentPosition);
            });
          });
        } else if (currentPosition == 12) {
          ladderPlayer.play(AssetSource('ladder.mp3'));
          Timer(const Duration(seconds: 1), () {
            setState(() {
              currentPosition = 14;
              positionIndex = paths.indexOf(currentPosition);
            });
          });
        } else if (currentPosition == 15) {
          ladderPlayer.play(AssetSource('ladder.mp3'));
          Timer(const Duration(seconds: 1), () {
            setState(() {
              currentPosition = 28;
              positionIndex = paths.indexOf(currentPosition);
            });
          });
        } else if (currentPosition == 23) {
          snakePlayer.play(AssetSource('snake.mp3'));
          Timer(const Duration(seconds: 1), () {
            setState(() {
              currentPosition = 16;
              positionIndex = paths.indexOf(currentPosition);
            });
          });
        } else if (currentPosition == 30) {
          snakePlayer.play(AssetSource('snake.mp3'));
          Timer(const Duration(seconds: 1), () {
            setState(() {
              currentPosition = 20;
              positionIndex = paths.indexOf(currentPosition);
            });
          });
        } else if (currentPosition == 35) {
          snakePlayer.play(AssetSource('snake.mp3'));
          Timer(const Duration(seconds: 1), () {
            setState(() {
              currentPosition = 24;
              positionIndex = paths.indexOf(currentPosition);
            });
          });
        } else if (currentPosition == 36) {
          bgmusicPlayer.play(AssetSource('snake_ladder.mp3'));
          Timer(const Duration(seconds: 1), () {
            setState(() {
              gameState = "COMPLETE";
            });
            UserCredential.increaseJackpotTicket(3);
          });
        }
      }
    });
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
  bool isGetChance = true;
  String toastMessage = '';

  loadInterstatialAd() {
    if (AdHelper.interstitialAdRequestTimes >=
        AdHelper.maxAdRequestTimesPerHour) {
      return;
    } else {
      AdHelper.interstitialAdRequestTimes++;
      InterstitialAd.load(
        adUnitId: AdHelper.snakeladderInterstitialAdUnitId,
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
              },
              onAdShowedFullScreenContent: (ad) {
                UserCredential.increasePoint();
                if (isGetChance) {
                  UserCredential.addFlipChance(3);
                } else {
                  setState(() {
                    rollChance = rollChance + 5;
                  });
                }
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                interstitialAd?.dispose();

                setState(() {
                  adReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                reloadAd();
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
              adReloadTimes++;
              AdHelper.runInterstitialAdTimer();
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

  AudioPlayer bgmusicPlayer = AudioPlayer();
  AudioPlayer stepPlayer = AudioPlayer();
  AudioPlayer rolldicePlayer = AudioPlayer();
  AudioPlayer ladderPlayer = AudioPlayer();
  AudioPlayer snakePlayer = AudioPlayer();

  Timer? _pointTimer;
  increasePoint() {
    _pointTimer = Timer(const Duration(minutes: 1), () {
      UserCredential.increasePoint();
      setState(() {});
    });
  }

  @override
  void initState() {
    bgmusicPlayer.play(AssetSource('snake_ladder.mp3'));
    loadInterstatialAd();
    loadAd();
    WakelockPlus.enable();
    increasePoint();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rollTimer?.cancel();
    _adTimer?.cancel();
    _pointTimer?.cancel();
    interstitialAd?.dispose();
    bgmusicPlayer.dispose();
    stepPlayer.dispose();
    rolldicePlayer.dispose();
    snakePlayer.dispose();
    ladderPlayer.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: const Alignment(0, 1),
        children: [
          selectCard(),
          adReady
              ? SizedBox(
                  width: double.infinity,
                  height: bannerAd?.size.height.toDouble(),
                  child: AdWidget(ad: bannerAd!),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget selectCard() {
    switch (gameState) {
      case "PLAY":
        return playCard();
      case 'COMPLETE':
        return completeCard();
      default:
        return homeCard();
    }
  }

  Widget homeCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('./lib/image/jackpot/princess_way.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('./lib/image/jackpot/paper.png'),
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Let's take\nour princess to the palace.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (UserCredential.flipChance > 0) {
                bgmusicPlayer.stop();
                resetGame();
                setState(() {
                  gameState = "PLAY";
                });
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: DesignProvider.getDialogBoxShape(10),
                    title: const Text("No Play Chance!"),
                    content: const Text(
                        "Sorry! You have no more play chance. Please watch ads or spand stars."),
                    actions: [
                      ElevatedButton(
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
            child: Image.asset(
              './lib/image/jackpot/play_2.png',
              width: 150,
            ),
          ),
          GestureDetector(
            onTap: () {
              bgmusicPlayer.stop();
              Navigator.pop(context);
            },
            child: Image.asset(
              './lib/image/jackpot/exit.png',
              width: 80,
            ),
          ),
          getPlayChanceCard(),
        ],
      ),
    );
  }

  Widget completeCard() {
    return SafeArea(
      child: Column(
        children: [
          Image.asset(
            './lib/image/jackpot/complete_message.gif',
            gaplessPlayback: false,
            fit: BoxFit.contain,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  bgmusicPlayer.stop();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 150,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      width: 5,
                    ),
                  ),
                  child: Text(
                    'E X I T',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (UserCredential.flipChance > 0) {
                    bgmusicPlayer.stop();
                    resetGame();
                    setState(() {
                      gameState = "PLAY";
                    });
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: DesignProvider.getDialogBoxShape(10),
                        title: const Text("No Play Chance!"),
                        content: const Text(
                            "Sorry! You have no more play chance. Please watch ads or spand stars."),
                        actions: [
                          ElevatedButton(
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
                child: Container(
                  width: 150,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      width: 5,
                    ),
                  ),
                  child: Text(
                    'PLAY AGAIN',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          getPlayChanceCard(),
        ],
      ),
    );
  }

  Widget playCard() {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('./lib/image/jackpot/snake_ladder.png'),
                  ),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6),
                  itemCount: 36,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: positionIndex == index
                          ? const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    './lib/image/jackpot/princess.png'),
                              ),
                            )
                          : null,
                      child: Text(
                        '${paths[index]}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow,
                              blurRadius: 2,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.background,
                      width: 5,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        blurRadius: 1,
                      )
                    ]),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Roll Chance:"),
                          Text(
                            '$rollChance',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!isRolling) {
                          if (rollChance > 0) {
                            rolldicePlayer
                                .play(AssetSource('roll_the_dice.mp3'));
                            rollChance--;
                            int rollCounter = 0;
                            _rollTimer = Timer.periodic(
                              const Duration(milliseconds: 200),
                              (timer) {
                                if (rollCounter < 2000) {
                                  setState(() {
                                    diceIndex = Random().nextInt(6);
                                  });
                                  rollCounter = rollCounter + 200;
                                } else {
                                  timer.cancel();
                                  movePosition(diceIndex + 1);
                                }
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: DesignProvider.getDialogBoxShape(10),
                                title: Text(
                                  'No roll chance!'.toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Text(
                                  "Sorry!, you have no more roll chance. Watch ads or spand a star to get 5 chance.",
                                  textAlign: TextAlign.justify,
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
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
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow,
                              blurRadius: 3,
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(dice[diceIndex]),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Required Steps:"),
                          Text(
                            '${36 - currentPosition}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              getChanceCard(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showGaveOver = true;
                  });
                },
                child: Container(
                  width: 150,
                  height: 40,
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 5,
                        color: Theme.of(context).colorScheme.background,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow,
                          blurRadius: 3,
                        ),
                      ]),
                  child: Text(
                    "E X I T",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          showGaveOver ? gameoverDialog() : Container(),
        ],
      ),
    );
  }

  Widget gameoverDialog() {
    return Container(
      color: Theme.of(context).colorScheme.shadow,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Image.asset(
                  './lib/image/jackpot/dudu-bubu.gif',
                  height: 80,
                ),
                Container(
                  width: 250,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Text("Are you sure to leave?"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showGaveOver = false;
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 40,
                        margin: const EdgeInsets.only(top: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.shadow,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 5,
                              color: Theme.of(context).colorScheme.background,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                blurRadius: 3,
                              ),
                            ]),
                        child: Text(
                          "N O",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 100,
                        height: 40,
                        margin: const EdgeInsets.only(top: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 5,
                              color: Theme.of(context).colorScheme.background,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                blurRadius: 3,
                              ),
                            ]),
                        child: Text(
                          "Y E S",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getChanceCard() {
    return Column(
      children: [
        Text(
          "If you don't have roll chance:",
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
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
                if (UserCredential.userProfile.remainedPoints < 1) {
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
                  Fluttertoast.showToast(msg: '5 roll chances added.');
                  UserCredential.deductPoints(1);

                  setState(() {
                    rollChance = rollChance + 5;
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

  Widget getPlayChanceCard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "You have: ${UserCredential.flipChance} play chance(s).",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          "If you don't have chance:",
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (adReady) {
                  bgmusicPlayer.stop();
                  toastMessage = 'You got 3 chances.';
                  isGetChance = true;
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
                if (UserCredential.userProfile.remainedPoints < 1) {
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
                  Fluttertoast.showToast(msg: '1 chance added.');
                  UserCredential.deductPoints(1);
                  UserCredential.addFlipChance(1);
                  setState(() {});
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
