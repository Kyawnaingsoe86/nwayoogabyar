import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/post.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:nwayoogabyar/view/viewpost.dart';

class ViewAll extends StatefulWidget {
  final String header;
  const ViewAll({super.key, required this.header});

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  List<Post> posts = [];
  List<Post> selectedPosts = [];
  List<String> genres = [];
  Post? selectedPost;
  int selectedIndex = 0;
  final int maxFailedLoadAttempts = 3;
  RewardedAd? _rewardedAd;

  bool adReady = false;
  bool isLoading = true;

  loadPosts() {
    posts = [];
    setState(() {
      isLoading = true;
    });
    Set<String> temp = {};
    for (int i = 0; i < UserCredential.posts.length; i++) {
      if (UserCredential.posts[i].category == widget.header) {
        posts.add(UserCredential.posts[i]);
        temp.add(UserCredential.posts[i].genre);
      }
    }
    genres = temp.toList();
    selectPosts(selectedIndex);
    setState(() {
      posts;
      isLoading = false;
    });
  }

  selectPosts(int index) {
    selectedPosts = [];
    for (int i = 0; i < posts.length; i++) {
      if (posts[i].genre == genres[index]) {
        selectedPosts.add(posts[i]);
      }
    }
    setState(() {
      selectedPosts;
    });
  }

  InterstitialAd? interstitialAd;
  int adFailTimes = 0;

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
                setState(() {});
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
                    ),
                  ),
                ).then((value) {
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

  BannerAd? bannerAd;
  bool isBannaAdLoaded = false;

  void loadAd() {
    bannerAd = BannerAd(
      adUnitId: AdHelper.bottomBannerAdUnitId,
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

  int counter = 10;
  Timer? _timer;
  bool adLoading = false;

  Widget postListCard(Post post) {
    bool postLiked = UserCredential.isPostLiked(post.postId);
    int likedCount = UserCredential.getLikeCount(post.postId);
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
                            Navigator.pop(context);
                            startAdTimer();
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
                                        Navigator.pop(context);
                                        startAdTimer();
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
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: UserCredential.isClicked(post.postId)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onPrimary,
            width: 5,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 1,
              color: Theme.of(context).colorScheme.shadow,
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
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
            ),
            Container(
              width: double.infinity,
              height: 25,
              alignment: Alignment.centerLeft,
              child: Text(
                post.enTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 20,
              child: Text(
                post.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 15,
              alignment: Alignment.centerRight,
              child: RichText(
                text: TextSpan(
                  text: '$likedCount ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 12,
                  ),
                  children: [
                    WidgetSpan(
                      child: Icon(
                        postLiked
                            ? Icons.thumb_up_off_alt_rounded
                            : Icons.thumb_up_alt_outlined,
                        size: 16,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  startAdTimer() {
    _timer?.cancel();
    if (adReady) return;
    _timer = Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
      if (AdHelper.interstitialAdRequestTimes <
          AdHelper.maxAdRequestTimesPerHour) {
        loadInterstatialAd();
      }
    });
  }

  @override
  void initState() {
    loadPosts();
    startAdTimer();
    loadAd();
    super.initState();
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    _rewardedAd?.dispose();
    bannerAd?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
        scrolledUnderElevation: 1,
        elevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: Text(
          widget.header.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 2,
          ),
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
                  adReady
                      ? EneftyIcons.magic_star_bold
                      : EneftyIcons.magic_star_outline,
                  color: adReady
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onBackground,
                ),
                adReady
                    ? Text(
                        '${UserCredential.userProfile.remainedPoints}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      )
                    : Text(
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
      body: isLoading
          ? const LoadingPage(
              title: 'e-Book',
              icon: EneftyIcons.book_square_outline,
              info: 'Loading...',
            )
          : Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: genres.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                              selectPosts(index);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: index == selectedIndex
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .background,
                                    width: 5,
                                  ),
                                ),
                              ),
                              child: Text(
                                genres[index].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: selectedPosts.length,
                          itemBuilder: (context, index) =>
                              postListCard(selectedPosts[index]),
                        ),
                      ),
                    ),
                  ],
                ),
                adLoading && counter > 0
                    ? Container(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.shadow,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 20),
                            Text(
                              'Wait for $counter seconds, ad is loading....',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
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
          : const SizedBox(),
    );
  }
}
