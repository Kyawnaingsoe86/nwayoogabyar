import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/sprf.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FlipCardGame extends StatefulWidget {
  const FlipCardGame({super.key});

  @override
  State<FlipCardGame> createState() => _FlipCardGameState();
}

class _FlipCardGameState extends State<FlipCardGame> {
  final List<String> cards = [
    './lib/image/jackpot/0.png',
    './lib/image/jackpot/0.png',
    './lib/image/jackpot/1.png',
    './lib/image/jackpot/1.png',
    './lib/image/jackpot/2.png',
    './lib/image/jackpot/2.png',
    './lib/image/jackpot/3.png',
    './lib/image/jackpot/3.png',
    './lib/image/jackpot/4.png',
    './lib/image/jackpot/4.png',
    './lib/image/jackpot/5.png',
    './lib/image/jackpot/5.png',
    './lib/image/jackpot/6.png',
    './lib/image/jackpot/6.png',
    './lib/image/jackpot/7.png',
    './lib/image/jackpot/7.png',
    './lib/image/jackpot/8.png',
    './lib/image/jackpot/8.png',
    './lib/image/jackpot/9.png',
    './lib/image/jackpot/9.png',
    './lib/image/jackpot/10.png',
    './lib/image/jackpot/10.png',
    './lib/image/jackpot/11.png',
    './lib/image/jackpot/11.png',
    './lib/image/jackpot/12.png',
    './lib/image/jackpot/12.png',
    './lib/image/jackpot/13.png',
    './lib/image/jackpot/13.png',
    './lib/image/jackpot/14.png',
    './lib/image/jackpot/14.png',
  ];
  final int gameDuration = 90;

  List<int> completeCards = [];
  String cardOne = '';
  String cardTwo = '';
  int cardOneIndex = -1;
  int cardTwoIndex = -1;
  int counter = 0;
  bool isComplete = false;
  String gameState = 'IDLE';
  int duration = 0;
  bool isTimeup = false;

  Timer? _timer;
  startTimer() {
    completeCards = [];
    cardOne = '';
    cardTwo = '';
    cardOneIndex = -1;
    cardTwoIndex = -1;
    counter = 0;
    cards.shuffle();
    setState(() {
      cards;
    });
    duration = gameDuration;
    callTimer();
  }

  callTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration == 0) {
        timer.cancel();
        setState(() {
          isTimeup = true;
        });
      } else {
        setState(() {
          duration = duration - 1;
        });
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

  int interAdTimer = 0;
  InterstitialAd? interstitialAd;
  int interAdReloadTimes = 0;
  bool interAdReady = false;
  Timer? _interAdTimer;
  String toastMessage = '';
  bool isBuyChance = true;

  loadInterstatialAd() {
    if (AdHelper.interstitialAdRequestTimes >=
        AdHelper.maxAdRequestTimesPerHour) {
      return;
    } else {
      AdHelper.interstitialAdRequestTimes++;
      InterstitialAd.load(
        adUnitId: AdHelper.flipcardInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                interstitialAd?.dispose();
                setState(() {
                  interAdReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                reloadInterstitialAd();
                adNotReadyDialog();
              },
              onAdShowedFullScreenContent: (ad) {
                UserCredential.increasePoint();
              },
              onAdDismissedFullScreenContent: (ad) {
                Fluttertoast.showToast(msg: toastMessage);
                if (isBuyChance) {
                  setState(() {
                    UserCredential.addFlipChance(3);
                  });
                } else {
                  setState(() {
                    duration = 45;
                    isTimeup = false;
                    callTimer();
                  });
                }
                ad.dispose();
                interstitialAd?.dispose();

                setState(() {
                  interAdReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                reloadInterstitialAd();
              },
            );
            interstitialAd = ad;
            setState(() {
              interAdReady = true;
            });
            interAdReloadTimes = 0;
            AdHelper.interstitialAdTimer?.cancel();
          },
          onAdFailedToLoad: (error) {
            setState(() {
              interAdReady = false;
            });
            if (interAdReloadTimes < 3) {
              AdHelper.runInterstitialAdTimer();
              interAdReloadTimes++;
              reloadInterstitialAd();
            }
          },
        ),
      );
    }
  }

  reloadInterstitialAd() {
    _interAdTimer =
        Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
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
    loadAd();
    loadInterstatialAd();
    cards.shuffle();
    setState(() {
      cards;
    });
    WakelockPlus.enable();
    increasePoint();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    bannerAd?.dispose();
    interstitialAd?.dispose();
    WakelockPlus.disable();
    _interAdTimer?.cancel();
    _pointTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip Card'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
        actions: [
          SizedBox(
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  interAdReady
                      ? EneftyIcons.magic_star_bold
                      : EneftyIcons.magic_star_outline,
                  color: interAdReady
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onBackground,
                ),
                Text(
                  '${UserCredential.userProfile.remainedPoints}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isBannaAdLoaded
          ? Container(
              color: Theme.of(context).colorScheme.background,
              width: bannerAd!.size.width.toDouble(),
              height: bannerAd!.size.height.toDouble(),
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: AdWidget(ad: bannerAd!),
            )
          : const SizedBox(height: 50),
      body: Stack(
        children: [
          changeCard(gameState),
          isTimeup ? timeupCard() : Container(),
        ],
      ),
    );
  }

  Widget changeCard(String stage) {
    switch (stage) {
      case "PLAYING":
        return cardsWidget();
      case "WIN":
        return winCard();
      case "GAMEOVER":
        return gameoverCard();
      default:
        return idleCard();
    }
  }

  Widget cardsWidget() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chance: ${UserCredential.flipChance}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Timer: $duration',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (!completeCards.contains(index) &&
                        cardOneIndex != index &&
                        cardTwoIndex != index) {
                      if (counter == 0) {
                        counter++;
                        setState(() {
                          cardOne = cards[index];
                          cardOneIndex = index;
                        });
                      } else if (counter == 1) {
                        counter = 0;
                        setState(() {
                          cardTwo = cards[index];
                          cardTwoIndex = index;
                        });
                        Timer(const Duration(milliseconds: 500), () {
                          if (cardOne == cardTwo) {
                            completeCards.add(cardOneIndex);
                            completeCards.add(cardTwoIndex);
                            if (completeCards.length == cards.length) {
                              _timer?.cancel();
                              setState(() {
                                duration = 0;
                                gameState = "WIN";
                                UserCredential.increaseJackpotTicket(3);
                              });
                            }
                          }
                          setState(() {
                            cardOne = '';
                            cardOneIndex = -1;
                            cardTwo = '';
                            cardTwoIndex = -1;
                          });
                        });
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(cards[index]),
                      ),
                    ),
                    child: (cardOneIndex == index || cardTwoIndex == index) ||
                            completeCards.contains(index)
                        ? Container()
                        : Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Icon(
                              EneftyIcons.game_outline,
                              size: 40,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget timeupCard() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.shadow,
      child: Center(
        child: Container(
          width: 300,
          height: 280,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                './lib/image/jackpot/timeup.gif',
                width: 100,
              ),
              const Text("Opp!! it's time up."),
              const Text(
                "You can extend timer by watching ads or using star!",
                textAlign: TextAlign.center,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: extendTimeCard(),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isTimeup = false;
                    gameState = "GAMEOVER";
                  });
                },
                child: Container(
                  width: 120,
                  height: 30,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('./lib/image/jackpot/exit_2.png'),
                      const Text('  Cancel'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget idleCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          margin: const EdgeInsets.only(top: 20),
          child: Image.asset('./lib/image/jackpot/letsplay.gif'),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "PLAY & WIN JACKET TICKETS",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (UserCredential.flipChance > 0) {
              setState(() {
                gameState = 'PLAYING';
                UserCredential.flipChance = UserCredential.flipChance - 1;
              });
              startTimer();
              Sprf().editFlipChance(UserCredential.flipChance);
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: DesignProvider.getDialogBoxShape(10),
                  title: const Text("No Chance"),
                  content: const Text(
                      "Sorry, you have no chance. Please watch ads or spend 2 stars."),
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
            width: 170,
            height: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('./lib/image/jackpot/play.png'),
              ),
            ),
          ),
        ),
        buyChanceSection(),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 60,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('./lib/image/jackpot/exit_1.png'),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buyChanceSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20),
          alignment: Alignment.center,
          child: Text("You have ${UserCredential.flipChance} chance(s)"),
        ),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 5),
          child: Text(
            "If you don't have chance:",
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
                if (interAdReady) {
                  toastMessage = 'You got 1 chance.';
                  isBuyChance = true;
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
                            if (interAdReloadTimes < 3) {
                              reloadInterstitialAd();
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
                            if (interAdReloadTimes < 3) {
                              reloadInterstitialAd();
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

  Widget extendTimeCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (interAdReady) {
              toastMessage = '45 seconds added.';
              isBuyChance = false;
              interstitialAd?.show();
            } else {
              adNotReadyDialog();
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
                        if (interAdReloadTimes < 3) {
                          interAdTimer = 60;
                          reloadInterstitialAd();
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              Fluttertoast.showToast(msg: '45 seconds added.');
              UserCredential.deductPoints(1);
              setState(() {
                duration = 45;
                callTimer();
                isTimeup = false;
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
                const Text('Use star'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> adNotReadyDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: DesignProvider.getDialogBoxShape(10),
        title: const Text('No Ads'),
        content: const Text('Sorry! Ads is not ready. Please try again later.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (interAdReloadTimes < 3) {
                interAdTimer = 60;
                reloadInterstitialAd();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget gameoverCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          './lib/image/jackpot/gameover.png',
          width: 200,
        ),
        GestureDetector(
          onTap: () {
            if (UserCredential.flipChance > 0) {
              setState(() {
                gameState = 'PLAYING';
                UserCredential.addFlipChance(-1);
              });
              startTimer();
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: DesignProvider.getDialogBoxShape(10),
                  title: const Text("No Chance"),
                  content: const Text(
                      "Sorry, you have no chance. Please watch ads or spend a star."),
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
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondaryContainer,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              'TRY AGAIN',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 150,
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 3,
                  ),
                ]),
            child: Text(
              'Exit',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        buyChanceSection(),
      ],
    );
  }

  Widget winCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            './lib/image/jackpot/congratulations.png',
            width: 100,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '"Congratulations"',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Text(
              "You win 3 jackpot tickets.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (UserCredential.flipChance > 0) {
                setState(() {
                  gameState = 'PLAYING';
                  UserCredential.addFlipChance(-1);
                });
                startTimer();
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: DesignProvider.getDialogBoxShape(10),
                    title: const Text("No Chance"),
                    content: const Text(
                        "Sorry, you have no chance. Please watch ads or spend a star."),
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
              width: 170,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 5,
                ),
              ),
              child: Text(
                'PLAY AGAIN!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 100,
              height: 40,
              margin: const EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 5,
                ),
              ),
              child: Text(
                'EXIT',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          buyChanceSection(),
        ],
      ),
    );
  }
}
