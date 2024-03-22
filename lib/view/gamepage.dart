import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/view/feedgame.dart';
import 'package:nwayoogabyar/view/imagepuzzle.dart';
import 'package:nwayoogabyar/view/appdrawer.dart';
import 'package:nwayoogabyar/view/flipcard.dart';
import 'package:nwayoogabyar/view/jackpot.dart';
import 'package:nwayoogabyar/view/myappbar.dart';
import 'package:nwayoogabyar/view/shoot.dart';
import 'package:nwayoogabyar/view/snakeladder.dart';
import 'package:nwayoogabyar/view/wordpizzel.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
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

  @override
  void initState() {
    loadAd();
    super.initState();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, false),
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: false,
      bottomNavigationBar: isBannaAdLoaded
          ? SizedBox(
              width: double.infinity,
              height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            )
          : null,
      body: Container(
        margin: const EdgeInsets.only(top: 10, left: 5, right: 5),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
          ),
          children: [
            gameCard(
              context,
              const JackPot(),
              'Jackpot',
              './lib/image/jackpot/game_1.png',
            ),
            gameCard(
              context,
              const FlipCardGame(),
              'Flip Card',
              './lib/image/jackpot/game_2.png',
            ),
            gameCard(
              context,
              const WordPuzzle(),
              'Word Puzzle',
              './lib/image/jackpot/game_3.png',
            ),
            gameCard(
              context,
              const ImagePuzzle(),
              'Image Puzzle',
              './lib/image/jackpot/game_4.png',
            ),
            gameCard(
              context,
              const SnakeLadderGame(),
              'Snake & Ladder',
              './lib/image/jackpot/game_5.png',
            ),
            gameCard(
              context,
              const ShootGame(),
              'SHOOT',
              './lib/image/jackpot/game_6.png',
            ),
            gameCard(
              context,
              const FeedGame(),
              'FEED ME',
              './lib/image/jackpot/game_7.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget gameCard(
      BuildContext context, Widget game, String name, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => game,
            )).then((value) {
          setState(() {});
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(3),
        child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 2,
                )
              ],
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.shadow,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Text(
                    name.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
