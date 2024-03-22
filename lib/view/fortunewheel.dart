import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/fortune.dart';

class FortuneWheelPage extends StatefulWidget {
  final String question;
  final int questionNumber;
  const FortuneWheelPage({
    super.key,
    required this.question,
    required this.questionNumber,
  });

  @override
  State<FortuneWheelPage> createState() => _FortuneWheelPageState();
}

class _FortuneWheelPageState extends State<FortuneWheelPage> {
  BannerAd? bannerAd;
  bool isAdLoad = false;
  initBannerAd() async {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bottomBannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isAdLoad = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );
    bannerAd?.load();
  }

  String answer = '';
  Color answerBGColor = Colors.transparent;
  List<String> cards = [
    './lib/image/jackpot/0.png',
    './lib/image/jackpot/1.png',
    './lib/image/jackpot/2.png',
    './lib/image/jackpot/3.png',
    './lib/image/jackpot/4.png',
    './lib/image/jackpot/5.png',
    './lib/image/jackpot/6.png',
    './lib/image/jackpot/7.png',
  ];

  int selectedIndex = -1;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    initBannerAd();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext mainContext) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select your answer'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: isAdLoad
          ? SizedBox(
              width: double.infinity,
              height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            )
          : const SizedBox(
              height: 50,
            ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              widget.question,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(showAnswer ? "The answer is:" : "Make a wish and tap the card."),
          showAnswer
              ? Container(
                  width: 250,
                  height: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        cards[selectedIndex],
                        width: 100,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        child: Text(
                          answer,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: 250,
                  height: 250,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            answer = FortuneQnA
                                .fortuneAnswers[widget.questionNumber][index];
                            showAnswer = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            image: DecorationImage(
                                image: AssetImage(cards[index])),
                          ),
                          child: selectedIndex == index
                              ? null
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .shadow,
                                        ),
                                      ]),
                                  child:
                                      const Icon(EneftyIcons.a_3d_cube_outline),
                                ),
                        ),
                      );
                    },
                  )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          )
        ],
      ),
    );
  }
}
