import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/controller/dateformatter.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/article.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/appdrawer.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:nwayoogabyar/view/myappbar.dart';
import 'package:nwayoogabyar/view/viewarticle.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticalPage extends StatefulWidget {
  const ArticalPage({super.key});

  @override
  State<ArticalPage> createState() => _ArticalPageState();
}

class _ArticalPageState extends State<ArticalPage> {
  bool adReady = false;
  bool isAdLimit = false;
  InterstitialAd? _interstitialAd;
  int selectedIndex = 0;

  List<Widget> imgList = [];

  Timer? _timer;
  int adFailTimes = 0;

  loadInterstitialAd() {
    if (AdHelper.interstitialAdRequestTimes >=
        AdHelper.maxAdRequestTimesPerHour) {
      return;
    } else {
      InterstitialAd.load(
        adUnitId: AdHelper.articleInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {},
              onAdDismissedFullScreenContent: (ad) {
                setState(() {
                  adReady = false;
                });

                ad.dispose();
                _interstitialAd?.dispose();

                AdHelper.runInterstitialAdTimer();
                startAdTimer();

                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewArticle(
                                article: selectedArticles[selectedIndex])))
                    .then((value) {
                  setState(() {});
                });
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd?.dispose();
                setState(() {
                  adReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                startAdTimer();
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewArticle(
                                article: selectedArticles[selectedIndex])))
                    .then((value) {
                  setState(() {});
                });
              },
            );

            _interstitialAd = ad;
            setState(() {
              adReady = true;
            });

            AdHelper.interstitialAdTimer?.cancel();
            adFailTimes = 0;
          },

          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            setState(() {
              adReady = false;
            });

            AdHelper.runInterstitialAdTimer();
            adFailTimes++;
            if (adFailTimes < 3) {
              startAdTimer();
            }
          },
        ),
      );
    }
  }

  startAdTimer() {
    _timer?.cancel();
    if (adReady) return;
    _timer = Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
      loadInterstitialAd();
    });
  }

  BannerAd? bottomBannerAd;
  bool isBottomBannaAdLoaded = false;

  void loadAd() {
    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bottomBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isBottomBannaAdLoaded = true;
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

  bool isLoading = true;
  String selectedCategory = '';
  List<Article> selectedArticles = [];

  setSelectedArticles() {
    selectedArticles = [];
    if (selectedCategory == 'All') {
      selectedArticles = UserCredential.articles;
    } else {
      for (int i = 0; i < UserCredential.articles.length; i++) {
        if (UserCredential.articles[i].category == selectedCategory) {
          selectedArticles.add(UserCredential.articles[i]);
        }
      }
    }
    setState(() {
      selectedArticles;
    });
  }

  loadQuotes() async {
    List<String> quotesImgLinks = await API().getQuotes();
    for (int i = 0; i < quotesImgLinks.length; i++) {
      imgList.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            image: DecorationImage(
              image: NetworkImage(quotesImgLinks[i]),
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
  }

  bool isReloading = false;

  loadArticles() async {
    setState(() {
      isLoading = true;
    });

    if (UserCredential.articles.isEmpty) {
      try {
        await API().getArticles();
        selectedCategory = UserCredential.articleCategories[0];
        setSelectedArticles();
        await loadQuotes();
        setState(() {
          isLoading = false;
          isReloading = false;
        });
      } on Exception catch (e) {
        setState(() {
          isReloading = true;
        });
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: DesignProvider.getDialogBoxShape(10),
              title: const Text("Error"),
              content: const Text("Server does not response! Try again."),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Timer(const Duration(seconds: 10), () {
                        setState(() {
                          isReloading = true;
                        });
                        loadArticles();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('OK')),
              ],
            ),
          );
        }
      }
    } else {
      selectedCategory = UserCredential.articleCategories[0];
      setSelectedArticles();
      setState(() {
        isLoading = false;
        isReloading = false;
      });
      _onRefresh();
    }
  }

  Future<void> _onRefresh() async {
    await API().getArticles();
    await loadQuotes();
    loadAd();
    selectedCategory = UserCredential.articleCategories[0];
    setSelectedArticles();
    setState(() {});
  }

  Widget articleCard(int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectedIndex = index;
        if (!UserCredential.isClicked(selectedArticles[index].id)) {
          UserCredential.setClickedId(selectedArticles[index].id);
          if (adReady) {
            _interstitialAd!.show();
          } else {
            startAdTimer();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ViewArticle(article: selectedArticles[index]),
              ),
            ).then((value) {
              setState(() {});
            });
          }
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          left: 5,
          right: 5,
          bottom: 10,
        ),
        padding: const EdgeInsets.only(bottom: 10),
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.black12,
        ))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      selectedArticles[index].titleEN,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            UserCredential.isClicked(selectedArticles[index].id)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(right: 4),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          selectedArticles[index].author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          selectedArticles[index].source,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      selectedArticles[index].contentEN,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 5),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DateFormatter.getPostedAge(
                        double.parse(selectedArticles[index].timestamp),
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.shadow,
                image: DecorationImage(
                  image: NetworkImage(selectedArticles[index].coverPhoto),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    loadAd();
    loadInterstitialAd();
    loadArticles();
    super.initState();
  }

  @override
  void dispose() {
    bottomBannerAd?.dispose();
    _interstitialAd?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, adReady),
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: false,
      body: Stack(
        children: [
          isLoading
              ? const LoadingPage(
                  title: 'Article',
                  icon: EneftyIcons.document_outline,
                  info: 'Loading...',
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // --- Youtube Channel Links ---
                      SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: UserCredential.ytchannelLinks.length,
                              itemBuilder: (context, index) {
                                List<String> channelInfo = UserCredential
                                    .ytchannelLinks[index]
                                    .split(',');
                                return SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: GestureDetector(
                                    onTap: () {
                                      launchUrl(
                                        Uri.parse(
                                          channelInfo[0],
                                        ),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                NetworkImage(channelInfo[2]),
                                          ),
                                          Text(
                                            channelInfo[1],
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              })),

                      // --- Category bar ---
                      Container(
                        width: double.infinity,
                        height: 35,
                        margin: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          top: 5,
                          bottom: 10,
                        ),
                        child: ListView.builder(
                          itemCount: UserCredential.articleCategories.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory =
                                      UserCredential.articleCategories[index];
                                });
                                setSelectedArticles();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 2,
                                ),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    width: UserCredential
                                                .articleCategories[index] ==
                                            selectedCategory
                                        ? 4
                                        : 0,
                                    color: UserCredential
                                                .articleCategories[index] ==
                                            selectedCategory
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                  )),
                                ),
                                child: Text(
                                  UserCredential.articleCategories[index]
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: UserCredential
                                                .articleCategories[index] ==
                                            selectedCategory
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // --- Article List ---
                      Expanded(
                        child: ListView.builder(
                          itemCount: selectedArticles.length,
                          itemBuilder: (context, index) {
                            return articleCard(index, context);
                          },
                        ),
                      ),

                      // --- Bottom Ad Widget ---
                      isBottomBannaAdLoaded
                          ? Container(
                              color: Theme.of(context).colorScheme.background,
                              width: bottomBannerAd!.size.width.toDouble(),
                              height: bottomBannerAd!.size.height.toDouble(),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: AdWidget(ad: bottomBannerAd!),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),

          // --- Reloading page overlay ---
          isReloading
              ? const LoadingPage(
                  title: 'Article',
                  icon: EneftyIcons.document_outline,
                  info: 'Re-Loading...',
                )
              : Container(),
        ],
      ),
    );
  }
}
