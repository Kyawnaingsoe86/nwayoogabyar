import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/post.dart';
import 'package:nwayoogabyar/model/profile.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/appdrawer.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:nwayoogabyar/view/myappbar.dart';
import 'package:nwayoogabyar/view/viewall.dart';
import 'package:nwayoogabyar/view/viewpost.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  Profile? userProfile;
  Post? selectedPost;

  bool isLoading = true;
  bool adReady = false;
  bool adLoading = false;
  int adFailTimes = 0;

  InterstitialAd? interstitialAd;
  loadInterstatialAd() {
    if (AdHelper.interstitialAdRequestTimes >=
        AdHelper.maxAdRequestTimesPerHour) {
      return;
    } else {
      AdHelper.interstitialAdRequestTimes++;
      InterstitialAd.load(
        adUnitId: AdHelper.ebookInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                UserCredential.increasePoint();
                UserCredential.setClickedId(selectedPost!.postId);
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                interstitialAd?.dispose();
                setState(() {
                  adReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                startAdTimer();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewPost(
                      post: selectedPost!,
                    ),
                  ),
                ).then((value) {
                  setState(() {});
                });
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                interstitialAd?.dispose();
                UserCredential.setClickedId(selectedPost!.postId);
                setState(() {
                  adReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                startAdTimer();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewPost(
                              post: selectedPost!,
                            ))).then((value) {
                  setState(() {});
                });
              },
            );

            interstitialAd = ad;
            AdHelper.interstitialAdTimer?.cancel();
            adFailTimes = 0;
            setState(() {
              adReady = true;
            });
          },
          onAdFailedToLoad: (error) {
            setState(() {
              adReady = false;
            });
            interstitialAd?.dispose();
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

  BannerAd? bottomBannerAd;
  bool isBottomBannaAdLoaded = false;
  BannerAd? topBannerAd;
  bool isTopBannaAdLoaded = false;

  void loadAd() {
    topBannerAd = BannerAd(
      adUnitId: AdHelper.topBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isTopBannaAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  bool isRealoading = false;
  getPosts() async {
    setState(() {
      isLoading = true;
    });
    if (UserCredential.posts.isEmpty) {
      try {
        await API().getPost();
        setState(() {
          isLoading = false;
          isRealoading = false;
        });
      } on Exception catch (e) {
        setState(() {
          isRealoading = true;
        });
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: DesignProvider.getDialogBoxShape(10),
              title: const Text("Error!!"),
              content: const Text("Server does not response.! Try again."),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Timer(const Duration(seconds: 20), () {
                      getPosts();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } else {
      setState(() {
        isLoading = false;
        isRealoading = false;
      });
    }
  }

  Future<void> reloadPage() async {
    await API().getPost();
    loadAd();
    startAdTimer();
    setState(() {});
  }

  Widget latestCard(Post post) {
    int likeCount = post.likedUserId.length ~/ 8;
    return GestureDetector(
      onTap: () {
        selectedPost = post;
        UserCredential.isClicked(post.postId)
            ? null
            : adReady
                ? interstitialAd!.show()
                : showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: DesignProvider.getDialogBoxShape(10),
                      title: const Text('No ads!!'),
                      content: const Text(
                          'Ads is not ready. You can read the post by using 1 star.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            startAdTimer();
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (UserCredential.deductPoints(1) < 0) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: DesignProvider.getDialogBoxShape(10),
                                  title: const Text('No enough stars!'),
                                  content: const Text(
                                      'Sorry, you have no enough star to read. Please watch ad'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        startAdTimer();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewPost(post: post))).then((value) {
                                setState(() {});
                              });
                              UserCredential.setClickedId(post.postId);
                              startAdTimer();
                              setState(() {});
                            }
                          },
                          child: const Text('Use Star'),
                        ),
                      ],
                    ),
                  );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              alignment: const Alignment(1, 1),
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        post.coverPhotoUrl == ''
                            ? 'https://i.ibb.co/6JbJVLW/Nway-Oo-Gabyar.png'
                            : post.coverPhotoUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Text(
                    post.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 45,
            margin: const EdgeInsets.only(top: 5),
            child: Text(
              post.enTitle.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 20,
            child: Text(
              post.author.length > 15
                  ? "${post.author.substring(0, 15)}..."
                  : post.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.shadow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 20,
            child: Text(
              "Like(s) : $likeCount",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Timer? _timer;
  startAdTimer() {
    _timer?.cancel();
    if (adReady) return;
    _timer = Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
      loadInterstatialAd();
    });
  }

  @override
  void initState() {
    getPosts();
    startAdTimer();
    loadAd();
    super.initState();
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    topBannerAd?.dispose();

    _timer?.cancel();
    super.dispose();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: myAppBar(context, adReady),
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: false,
      body: RefreshIndicator(
        onRefresh: reloadPage,
        child: Stack(children: [
          isLoading
              ? const LoadingPage(
                  title: 'e-Book',
                  icon: EneftyIcons.book_square_outline,
                  info: 'Loading...',
                )
              : Column(
                  children: [
                    isTopBannaAdLoaded
                        ? Container(
                            width: double.infinity,
                            height: 60,
                            margin: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 2,
                            ),
                            child: AdWidget(ad: topBannerAd!),
                          )
                        : const SizedBox(),
                    Container(
                      width: double.infinity,
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: UserCredential.categories.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewAll(
                                            header: UserCredential
                                                .categories[index],
                                          ))).then((value) {
                                setState(() {});
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 2,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              ),
                              child: Text(
                                UserCredential.categories[index].toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 5, bottom: 5),
                      child: Text(
                        "Latest".toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: GridView.builder(
                          itemCount: 12,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.5,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            return latestCard(UserCredential.posts[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
          isRealoading
              ? const LoadingPage(
                  title: 'e-Book',
                  icon: EneftyIcons.book_square_outline,
                  info: 'Re-Loading...',
                )
              : Container(),
        ]),
      ),
    );
  }
}
