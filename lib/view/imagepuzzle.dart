import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/puzzleimage.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ImagePuzzle extends StatefulWidget {
  const ImagePuzzle({super.key});

  @override
  State<ImagePuzzle> createState() => _ImagePuzzleState();
}

class _ImagePuzzleState extends State<ImagePuzzle> {
  List<PuzzleImage> puzzleImages = [];
  bool isLoading = true;
  String wholeImage = '';
  List<Map> puzzles = [];
  List<Map> userResult = [];
  int selectedIndex = -1;
  int completeCards = 0;
  String gameState = 'IDLE';
  Timer? gameTimer;
  Timer? reloadTimer;
  int counter = 0;
  int imageIndex = -1;

  getPuzzleImages() async {
    setState(() {
      isLoading = true;
    });
    try {
      reloadTimer?.cancel();
      puzzleImages = await API().getPuzzleImages();
      setState(() {
        isLoading = false;
        puzzleImages;
      });
    } on Exception catch (e) {
      reloadTimer = Timer(const Duration(seconds: 10), () {
        getPuzzleImages();
      });
    }
  }

  startGame(int index) {
    gameTimer?.cancel();
    imageIndex = index;
    wholeImage = puzzleImages[index].img;
    puzzles = [];
    for (int i = 0; i < puzzleImages[index].puzzleImages.length; i++) {
      puzzles.add(puzzleImages[index].puzzleImages[i]);
    }
    puzzles.shuffle();
    userResult = [];
    userResult = [
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
      {'index': -1, 'img': ''},
    ];
    setState(() {
      wholeImage;
      puzzles;
      userResult;
      selectedIndex = -1;
      completeCards = 0;
      counter = 60;
      gameState = "PLAY";
    });
    Timer(const Duration(seconds: 3), () {
      startGameTimer();
    });
  }

  startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter == 0) {
        setState(() {
          gameState = 'TIMEUP';
        });
        timer.cancel;
      } else {
        setState(() {
          counter = counter - 1;
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
              },
              onAdShowedFullScreenContent: (ad) {
                UserCredential.addFlipChance(3);
                UserCredential.increasePoint();
              },
              onAdDismissedFullScreenContent: (ad) {
                Fluttertoast.showToast(msg: 'You got 3 chances.');
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
    getPuzzleImages();
    loadAd();
    reloadAd();
    WakelockPlus.enable();
    increasePoint();
    super.initState();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    gameTimer?.cancel();
    _pointTimer?.cancel();
    reloadTimer?.cancel();
    bannerAd?.dispose();
    interstitialAd?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Puzzle'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
      ),
      body: isLoading
          ? const LoadingPage(
              title: 'Loading', icon: Icons.image, info: 'Please Wait')
          : AnimatedContainer(
              duration: const Duration(seconds: 1),
              child: SingleChildScrollView(
                child: switchCard(gameState),
              ),
            ),
      bottomNavigationBar: isBannaAdLoaded
          ? SizedBox(
              width: double.infinity,
              height: bannerAd?.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            )
          : null,
    );
  }

  Widget switchCard(String stage) {
    switch (stage) {
      case "PLAY":
        return playCard();
      case "SELECT_IMAGE":
        return selectImageCard();
      case "TIMEUP":
        return timeupCard();
      case "COMPLETE":
        return completeCard();
      default:
        return homeCard();
    }
  }

  Widget completeCard() {
    return Column(
      children: [
        Text(
          'WELL DONE',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.background,
                width: 10,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 3,
                ),
              ]),
          child: Image.network(puzzleImages[imageIndex].img),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: Container(
                width: 120,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "EXIT",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (UserCredential.flipChance <= 0) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: DesignProvider.getDialogBoxShape(10),
                      title: const Text('No chance'),
                      content: const Text(
                          'Sorry! You have no chance. Please watch ads or spand 2 stars.'),
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
                  UserCredential.addFlipChance(-1);
                  setState(() {
                    gameState = "SELECT_IMAGE";
                  });
                }
              },
              child: Container(
                width: 120,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "PLAY NEXT",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        getChanceCard(),
      ],
    );
  }

  Widget timeupCard() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset(
            './lib/image/jackpot/timeup.gif',
            width: 200,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              if (UserCredential.flipChance > 0) {
                UserCredential.addFlipChance(-1);
                startGame(imageIndex);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: DesignProvider.getDialogBoxShape(10),
                    title: const Text('No chance'),
                    content: const Text(
                        'Sorry! You have no chance. Please watch ads or spand 2 stars.'),
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
              width: 170,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Retry",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                gameTimer?.cancel();
                gameState = 'IDEL';
              });
            },
            child: Container(
              width: 100,
              height: 40,
              margin: const EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Back",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          getChanceCard(),
        ],
      ),
    );
  }

  Widget selectImageCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 10),
          child: const Text(
            'Select image:',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(8),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: puzzleImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  startGame(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      width: 5,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(puzzleImages[index].img),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget homeCard() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 80),
          Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('./lib/image/jackpot/game_4.png'),
                fit: BoxFit.contain,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (UserCredential.flipChance <= 0) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: DesignProvider.getDialogBoxShape(10),
                    title: const Text('No chance'),
                    content: const Text(
                        'Sorry! You have no chance. Please watch ads or spand 2 stars.'),
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
                UserCredential.addFlipChance(-1);
                setState(() {
                  gameState = "SELECT_IMAGE";
                });
              }
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 30),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('./lib/image/jackpot/play.png'),
                ),
              ),
            ),
          ),
          getChanceCard()
        ],
      ),
    );
  }

  Widget getChanceCard() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "You have: ${UserCredential.flipChance} chance(s).",
            style: TextStyle(
              color: Theme.of(context).colorScheme.shadow,
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

  Widget playCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                          color: Theme.of(context).colorScheme.background,
                          width: 3,
                        )),
                      ),
                      child: const Text('Chance:'),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        '${UserCredential.flipChance}',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 3,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(wholeImage),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                          color: Theme.of(context).colorScheme.background,
                          width: 3,
                        )),
                      ),
                      child: const Text('Time:'),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        '$counter',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.all(8),
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              if (userResult[index]['img'] == '') {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      border: selectedIndex == index
                          ? Border.all(
                              color: Colors.amber,
                              width: 2,
                            )
                          : Border.all(
                              color: Theme.of(context).colorScheme.shadow,
                              width: 0.5,
                            ),
                    ),
                    child: Text('${index + 1}'),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    if (userResult[index]['index'] != index) {
                      puzzles.add(userResult[index]);
                      userResult[index] = {'index': -1, 'img': ''};
                      setState(() {
                        userResult;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: selectedIndex == index
                          ? Border.all(
                              color: Colors.amber,
                              width: 2,
                            )
                          : userResult[index]['index'] == index
                              ? null
                              : Border.all(
                                  color: Colors.red,
                                  width: 2,
                                ),
                    ),
                    child: Image.network(userResult[index]['img']),
                  ),
                );
              }
            },
          ),
        ),
        Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.only(bottom: 10),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            children: List.generate(
              puzzles.length,
              (index) => GestureDetector(
                onTap: () {
                  if (selectedIndex > -1) {
                    userResult[selectedIndex] = puzzles[index];
                    if (selectedIndex == puzzles[index]['index']) {
                      setState(() {
                        completeCards++;
                      });
                    }
                    puzzles.removeAt(index);
                    setState(() {
                      puzzles;
                      selectedIndex = -1;
                    });
                    if (completeCards == 16) {
                      gameTimer?.cancel();
                      Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          gameState = "COMPLETE";
                        });
                      });
                    }
                  }
                },
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("${puzzles[index]['img']}"),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
