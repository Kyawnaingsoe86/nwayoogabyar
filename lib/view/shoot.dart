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

class ShootGame extends StatefulWidget {
  const ShootGame({super.key});

  @override
  State<ShootGame> createState() => _ShootGameState();
}

class _ShootGameState extends State<ShootGame> {
  String gameState = "IDLE";
  int botLevel = 0;
  int playerLevel = 0;
  bool isPlayerTurn = true;
  bool isRolling = false;
  List<String> diceOne = [
    "./lib/image/jackpot/dice_1.png",
    "./lib/image/jackpot/dice_2.png",
  ];

  List<String> diceTwo = [
    "./lib/image/jackpot/dice_1.png",
    "./lib/image/jackpot/dice_2.png",
  ];

  int diceOneIndex = 0;
  int diceTwoIndex = 0;

  AudioPlayer rollPlayer = AudioPlayer();
  AudioPlayer noPlayer = AudioPlayer();
  AudioPlayer yesPlayer = AudioPlayer();
  AudioPlayer homePlayer = AudioPlayer();
  AudioPlayer winPlayer = AudioPlayer();
  AudioPlayer losePlayer = AudioPlayer();
  AudioPlayer endPlayer = AudioPlayer();

  resetGame() {
    setState(() {
      botLevel = 0;
      playerLevel = 0;
      isPlayerTurn = true;
      isRolling = false;
      diceOneIndex = 0;
      diceTwoIndex = 0;
    });
  }

  Timer? _timer;
  rollDice() {
    rollPlayer.play(AssetSource('roll_the_dice.mp3'));
    int counter = 2000;
    isRolling = true;
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (counter <= 0) {
        timer.cancel();

        if (diceOneIndex == diceTwoIndex) {
          yesPlayer.play(AssetSource('shoot_yes.mp3'));
          if (isPlayerTurn) {
            setState(() {
              playerLevel = playerLevel + 1;
            });
            if (playerLevel < 13) {
              Timer(const Duration(seconds: 2), () {
                botTurn();
              });
            } else {
              winPlayer.play(AssetSource('shoot_win.mp3'));
              setState(() {
                botLevel = 14;
              });
              Timer(const Duration(seconds: 2), () {
                endPlayer.play(AssetSource("shoot_end.mp3"));
                UserCredential.increaseJackpotTicket(1);
                setState(() {
                  gameState = "WIN";
                });
              });
            }
          } else {
            setState(() {
              botLevel = botLevel + 1;
              if (botLevel < 13) {
                Timer(const Duration(seconds: 2), () {
                  setState(() {
                    isPlayerTurn = true;
                    isRolling = false;
                  });
                });
              } else {
                losePlayer.play(AssetSource('shoot_lose.mp3'));
                setState(() {
                  playerLevel = 14;
                });
                Timer(const Duration(seconds: 2), () {
                  endPlayer.play(AssetSource('shoot_end.mp3'));
                  setState(() {
                    UserCredential.addFlipChance(-1);
                    gameState = "LOSE";
                  });
                });
              }
            });
          }
        } else {
          noPlayer.play(AssetSource('shoot_no.mp3'));
          if (isPlayerTurn) {
            Timer(const Duration(seconds: 2), () {
              botTurn();
            });
          } else {
            Timer(const Duration(seconds: 2), () {
              setState(() {
                isPlayerTurn = true;
                isRolling = false;
              });
            });
          }
        }
      } else {
        counter = counter - 200;
        setState(() {
          diceOneIndex = Random().nextInt(2);
          diceTwoIndex = Random().nextInt(2);
        });
      }
    });
  }

  botTurn() {
    setState(() {
      isPlayerTurn = false;
    });
    rollDice();
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

  InterstitialAd? _interstitialAd;
  bool adReady = false;
  int adRequestTimes = 0;

  void loadInterstitialAd() {
    if (AdHelper.interstitialAdRequestTimes >=
        AdHelper.maxAdRequestTimesPerHour) {
      return;
    } else {
      InterstitialAd.load(
        adUnitId: AdHelper.shootInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  UserCredential.addFlipChance(3);
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
                  Fluttertoast.showToast(msg: 'You got 3 life.');
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
            debugPrint('Interstitial failed to load: $error');
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

  Timer? _interstitialAdTimer;

  startAdTimer() {
    _interstitialAdTimer?.cancel();
    if (adReady) return;
    _interstitialAdTimer =
        Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
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
    homePlayer.play(AssetSource('shoot_home.mp3'));
    startAdTimer();
    WakelockPlus.enable();
    loadAd();
    increasePoint();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pointTimer?.cancel();
    homePlayer.dispose();
    endPlayer.dispose();
    yesPlayer.dispose();
    noPlayer.dispose();
    winPlayer.dispose();
    losePlayer.dispose();
    _interstitialAdTimer?.cancel();
    _interstitialAd?.dispose();
    bannerAd?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: changeGameCard(),
        bottomNavigationBar: isBannaAdLoaded
            ? SizedBox(
                width: double.infinity,
                height: bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: bannerAd!),
              )
            : const SizedBox(
                width: double.infinity,
                height: 60,
              ),
      ),
    );
  }

  Widget changeGameCard() {
    switch (gameState) {
      case "PLAY":
        return playCard();
      case "WIN":
        return winCard();
      case "LOSE":
        return loseCard();
      default:
        return idleCard();
    }
  }

  Widget loseCard() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'YOU LOSE',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Image.asset(
            './lib/image/jackpot/die.gif',
            width: 200,
          ),
          const SizedBox(height: 20),
          replayButton(),
          const SizedBox(height: 20),
          exitButton(),
          const SizedBox(height: 20),
          getPlayChanceCard(),
        ],
      ),
    );
  }

  Widget winCard() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "YOU WIN",
            style: TextStyle(
              color: Colors.red,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text("You got a jackpot ticket from the bot."),
          Image.asset(
            "./lib/image/jackpot/dance.gif",
            height: 150,
          ),
          const SizedBox(height: 20),
          replayButton(),
          const SizedBox(height: 20),
          exitButton(),
          const SizedBox(height: 20),
          getPlayChanceCard(),
        ],
      ),
    );
  }

  Widget replayButton() {
    return GestureDetector(
      onTap: () {
        if (UserCredential.flipChance > 0) {
          endPlayer.stop();
          setState(() {
            resetGame();
            gameState = "PLAY";
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: DesignProvider.getDialogBoxShape(10),
              title: const Text("No Life!"),
              content: const Text(
                  "You have no more life. Please watch ads or spand 2 stars."),
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
      child: Image.asset(
        './lib/image/jackpot/shoot_replay.png',
        height: 70,
      ),
    );
  }

  Widget exitButton() {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Image.asset(
          './lib/image/jackpot/shoot_exit.png',
          height: 50,
        ));
  }

  Widget playCard() {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ---- LOGO ----
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(
                './lib/image/jackpot/shoot.png',
                height: 70,
              ),
            ),

            // --- Description ---
            Text(
              "Shoot the bot and get a jackpot ticket.".toUpperCase(),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            // --- life -----
            Container(
              width: double.infinity,
              height: 60,
              alignment: Alignment.center,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 20,
                  ),
                  children: UserCredential.flipChance < 10
                      ? List.generate(
                          UserCredential.flipChance,
                          (index) => const TextSpan(text: '🤠'),
                        )
                      : [
                          TextSpan(
                              text:
                                  "You have : ${UserCredential.flipChance} life.")
                        ],
                ),
              ),
            ),

            // ---- Level Display ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  color: Theme.of(context).colorScheme.background,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.onBackground,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "YOU",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.background,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text('Level:'),
                      ),
                      Text(
                        playerLevel < 13
                            ? '$playerLevel'
                            : playerLevel == 13
                                ? "WIN"
                                : "LOSE",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
                Container(
                  width: 120,
                  color: Theme.of(context).colorScheme.background,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.onBackground,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "BOT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.background,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text('Level:'),
                      ),
                      Text(
                        botLevel < 13
                            ? "$botLevel"
                            : botLevel == 13
                                ? "WIN"
                                : 'LOSE',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ---- Body Section ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    image: DecorationImage(
                      image: AssetImage(
                          './lib/image/jackpot/shootPlayer/$playerLevel.png'),
                    ),
                    border: isPlayerTurn
                        ? Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2,
                          )
                        : null,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Image.asset(
                        diceOne[diceOneIndex],
                        width: 40,
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        diceTwo[diceTwoIndex],
                        width: 40,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    image: DecorationImage(
                      image: AssetImage(
                          './lib/image/jackpot/shootBot/$botLevel.png'),
                    ),
                    border: !isPlayerTurn
                        ? Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2,
                          )
                        : null,
                  ),
                ),
              ],
            ),

            // ---- Button Section ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isPlayerTurn && !isRolling) {
                      rollDice();
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 40,
                    margin: const EdgeInsets.only(top: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isPlayerTurn
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      !isRolling
                          ? 'R O L L'
                          : isPlayerTurn
                              ? "R O L L I N G"
                              : "W A I T",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 60),
                Container(
                  width: 120,
                  height: 40,
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isPlayerTurn
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    !isPlayerTurn ? 'R O L L I N G' : "W A I T",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                './lib/image/jackpot/shoot_exit.png',
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget idleCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 30),
          alignment: Alignment.center,
          child: Image.asset(
            './lib/image/jackpot/shoot.png',
            width: 300,
          ),
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
                  title: const Text("No Life!"),
                  content: const Text(
                      "You have no more life. Please watch ads or spand 2 stars."),
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
          child: Image.asset(
            './lib/image/jackpot/shoot_play.png',
            height: 70,
          ),
        ),
        const SizedBox(height: 20),
        exitButton(),
        const SizedBox(height: 20),
        getPlayChanceCard(),
      ],
    );
  }

  Widget getPlayChanceCard() {
    return Column(
      children: [
        const Text("You have:"),
        // --- life -----
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 20,
              ),
              children: UserCredential.flipChance < 10 &&
                      UserCredential.flipChance > 0
                  ? List.generate(
                      UserCredential.flipChance,
                      (index) => const TextSpan(text: '🤠'),
                    )
                  : [TextSpan(text: "${UserCredential.flipChance} life.")],
            ),
          ),
        ),
        const SizedBox(height: 20),
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
                  homePlayer.stop();
                  endPlayer.stop();
                  _interstitialAd?.show();
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
                            if (adRequestTimes < 3) {
                              startAdTimer();
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
                  color: Theme.of(context).colorScheme.background,
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
                homePlayer.stop();
                endPlayer.stop();
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
                            if (adRequestTimes < 3) {
                              startAdTimer();
                            }
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  Fluttertoast.showToast(msg: '1 life added.');
                  UserCredential.deductPoints(1);
                  UserCredential.addFlipChance(1);
                  setState(() {});
                }
              },
              child: Container(
                width: 120,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
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
