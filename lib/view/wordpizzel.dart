import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WordPuzzle extends StatefulWidget {
  const WordPuzzle({super.key});

  @override
  State<WordPuzzle> createState() => _WordPuzzleState();
}

class _WordPuzzleState extends State<WordPuzzle> {
  String gameStatus = 'LOADING';
  int level = 0;
  String word = '';
  String pic = '';
  List<String> puzzle = [];
  List<List<dynamic>> answer = [];
  List<int> selectedIndex = [];
  String answerWord = '';
  int length = 0;
  int inputCount = -1;
  bool complete = false;
  bool wrong = false;

  bool isLoading = true;
  List<List<String>> words = [];

  loadWords() async {
    setState(() {
      isLoading = true;
    });
    try {
      words = await API().getWordPuzzle();
    } on Exception catch (e) {
      Timer(const Duration(seconds: 10), () {
        loadWords();
      });
    }
    setState(() {
      isLoading = false;
      gameStatus = 'IDLE';
    });
  }

  startGame(int level) {
    word = words[level][0];
    pic = words[level][1];
    length = word.length;
    puzzle = word.split('');
    puzzle.shuffle();
    answer = [];
    complete = false;
    for (int i = 0; i < length; i++) {
      answer.add([-1, '']);
    }
    setState(() {
      gameStatus = "PLAY";
      puzzle;
      complete;
      answer;
      selectedIndex = [];
      answerWord = '';
      length;
      inputCount = -1;
      complete = false;
      wrong = false;
      counter = 30;
    });
    Timer(const Duration(seconds: 2), () {
      startGameTimer();
    });
  }

  reset() {
    answer = [];
    complete = false;
    for (int i = 0; i < length; i++) {
      answer.add([-1, '']);
    }
    setState(() {
      answer;
      selectedIndex = [];
      answerWord = '';
      inputCount = -1;
      complete = false;
      wrong = false;
    });
  }

  int counter = 0;
  Timer? _gameTimer;

  startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter == 1) {
        timer.cancel();
        setState(() {
          gameStatus = "TIMEUP";
        });
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
      size: AdSize.largeBanner,
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

  loadInterstatialAd() {
    if (AdHelper.interstitialAdRequestTimes >=
        AdHelper.maxAdRequestTimesPerHour) {
      return;
    } else {
      AdHelper.interstitialAdRequestTimes++;
      InterstitialAd.load(
        adUnitId: AdHelper.wordpuzzleInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdFailedToShowFullScreenContent: (ad, error) {
                startGame(level);
                ad.dispose();
                interstitialAd?.dispose();
                setState(() {
                  interAdReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                reloadInterstitialAd();
              },
              onAdShowedFullScreenContent: (ad) {
                UserCredential.increasePoint();
              },
              onAdDismissedFullScreenContent: (ad) {
                startGame(level);
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
              interAdReloadTimes++;
              AdHelper.runInterstitialAdTimer();
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
    level = UserCredential.userProfile.wordPuzzleLevel;
    loadWords();
    loadAd();
    loadInterstatialAd();
    WakelockPlus.enable();
    increasePoint();
    super.initState();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _interAdTimer?.cancel();
    _pointTimer?.cancel();
    bannerAd?.dispose();
    interstitialAd?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 1,
        elevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow,
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
        title: const Text(
          'WORD PUZZLE',
        ),
        titleSpacing: 0,
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
      body: getGameCard(gameStatus),
      bottomNavigationBar: isBannaAdLoaded
          ? SizedBox(
              width: double.infinity,
              height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            )
          : null,
    );
  }

  Widget getGameCard(String gameStatus) {
    switch (gameStatus) {
      case 'LOADING':
        return const LoadingPage(
            title: 'Loading',
            icon: EneftyIcons.game_outline,
            info: 'Loading...');
      case 'PLAY':
        return playCard();
      case 'COMPLETE':
        return completeCard();
      case 'TIMEUP':
        return timeupCard();
      default:
        return idleCard();
    }
  }

  Widget timeupCard() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            './lib/image/jackpot/timeup.gif',
            width: 150,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              UserCredential.userProfile.wordPuzzleLevel = level;
              if (interAdReady) {
                interstitialAd?.show();
              } else {
                startGame(level);
              }
            },
            child: Container(
              width: 200,
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 3,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'TRY AGAIN!!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 200,
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 3,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'EXIT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget idleCard() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('./lib/image/jackpot/game_3.png'),
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
          ),
          Text(
            'YOU COMPLETE: $level WORD(s)',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                gameStatus = 'PLAY';
                UserCredential.userProfile.wordPuzzleLevel = level;
                startGame(level);
              });
            },
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('./lib/image/jackpot/start.png'),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 80,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('./lib/image/jackpot/exit_1.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget completeCard() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            './lib/image/jackpot/welldone.gif',
            width: 150,
          ),
          Text(
            level == words.length - 1 ? 'You have complete all word.' : "",
          ),
          GestureDetector(
            onTap: () {
              if (level < words.length - 1) {
                level++;
                UserCredential.userProfile.wordPuzzleLevel = level;
                if (interAdReady) {
                  interstitialAd?.show();
                } else {
                  startGame(level);
                }
              } else {
                level = 0;
                UserCredential.userProfile.wordPuzzleLevel = level;
                if (interAdReady) {
                  interstitialAd?.show();
                } else {
                  startGame(level);
                }
              }
            },
            child: Container(
              width: 200,
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 3,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                (level < words.length - 1) ? 'NEXT WORD' : 'RESET',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              level++;
              UserCredential.userProfile.wordPuzzleLevel = level;
              API().editWordPuzzleLevel();
              Navigator.pop(context);
            },
            child: Container(
              width: 200,
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 3,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'EXIT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget playCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            alignment: Alignment.centerRight,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.yellow,
              child: Text(
                '$counter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: counter > 5 ? Colors.black : Colors.red,
                ),
              ),
            ),
          ),
          Container(
            width: 280,
            height: 150,
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(pic),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Wrap(
            spacing: 4.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: List.generate(
              length,
              (index) => GestureDetector(
                onTap: () {
                  if (!complete) {
                    selectedIndex.remove(answer[index][0]);
                    answer.removeAt(index);
                    answer.add([-1, '']);
                    inputCount--;
                    setState(() {
                      selectedIndex;
                      answer;
                      inputCount;
                      wrong = false;
                    });
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: complete
                        ? Colors.greenAccent
                        : wrong
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(answer[index][1].toUpperCase()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 4.0, // gap between adjacent chips
            runSpacing: 8.0, // gap between lines
            children: List.generate(
              length,
              (index) => GestureDetector(
                onTap: () {
                  if (!selectedIndex.contains(index)) {
                    selectedIndex.add(index);
                    inputCount++;
                    answer[inputCount] = [index, puzzle[index]];
                    answerWord = '';
                    for (int i = 0; i < answer.length; i++) {
                      answerWord = answerWord + answer[i][1];
                    }
                    setState(() {
                      answer;
                      if (answerWord.length == length && word == answerWord) {
                        complete = true;
                        wrong = false;

                        API().editWordPuzzleLevel();
                        Timer(const Duration(milliseconds: 500), () {
                          _gameTimer?.cancel();
                          setState(() {
                            gameStatus = "COMPLETE";
                          });
                        });
                      } else if (answerWord.length == length &&
                          word != answerWord) {
                        wrong = true;
                      }
                    });
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: selectedIndex.contains(index)
                        ? Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Text(puzzle[index].toUpperCase()),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: reset,
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('./lib/image/jackpot/reset.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
