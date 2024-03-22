import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/controller/dateformatter.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/blogpost.dart';
import 'package:nwayoogabyar/model/profile.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/addblogpost.dart';
import 'package:nwayoogabyar/view/appdrawer.dart';
import 'package:nwayoogabyar/view/blogprofile.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:nwayoogabyar/view/myappbar.dart';
import 'package:nwayoogabyar/view/uploadstory.dart';
import 'package:nwayoogabyar/view/viewblogpost.dart';
import 'package:nwayoogabyar/view/viewstoryphoto.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  bool isLoading = true;
  bool isReloading = false;
  BlogPost? clickPost;

  getBlogPost() async {
    if (UserCredential.blogPosts.isEmpty) {
      try {
        setState(() {
          isLoading = true;
        });
        //await API().getStoryPhoto();
        await API().getBlogPost();
        await API().getBlogComment();
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
              title: const Text("error"),
              content: const Text("Server does not response! Try again."),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Timer(const Duration(seconds: 15), () {
                        getBlogPost();
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
      setState(() {
        setState(() {
          isLoading = false;
          isReloading = false;
        });
      });
      _onRefresh();
    }
  }

  Widget postCard(BlogPost post) {
    String postText = '';
    String imageText = '';

    int lenght = post.post.length;
    int index = post.post.indexOf('![img]');

    if (index > -1) {
      postText = post.post.substring(0, index - 2);
      imageText = post.post.substring(index + 7, lenght - 1);
    } else {
      postText = post.post;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(
        top: 4,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Column(
        children: [
          // --- Profile Tile ---
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            onTap: () {
              if (adReady) {
                clickPost = post;
                interstitialAd!.show();
              } else {
                startAdTimer();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewBlogPost(post: post),
                    )).then((value) async {
                  setState(() {
                    UserCredential.blogPosts;
                  });
                  await API().getBlogPost();
                  await API().getBlogComment();
                  setState(() {});
                });
              }
            },
            leading: GestureDetector(
              onTap: () {
                Profile blogProfile =
                    UserCredential.getBlogProfile(post.userId)!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogProfile(blogProfile: blogProfile),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.background,
                backgroundImage:
                    getImage(UserCredential.getUserAvatar(post.userId)),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    UserCredential.getUserName(post.userId),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                post.userId == UserCredential.userProfile.id
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddBlogPost(post: post, isAddNew: false),
                              )).then((value) {
                            setState(() {
                              UserCredential.blogPosts;
                              UserCredential.blogComments;
                              UserCredential.replyBlogComments;
                            });
                          });
                        },
                        child: const Icon(EneftyIcons.edit_2_outline),
                      )
                    : Container(),
              ],
            ),
            subtitle: Text(
              DateFormatter.getDateTimeFromDouble(double.parse(post.timestamp)),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),

          // --- Post Preview Section ---
          GestureDetector(
            onTap: () {
              if (adReady) {
                clickPost = post;
                interstitialAd!.show();
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewBlogPost(post: post),
                    )).then((value) async {
                  setState(() {
                    UserCredential.blogPosts;
                  });
                  await API().getBlogPost();
                  await API().getBlogComment();
                  setState(() {});
                });
              }
            },
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  child: Text(
                    postText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                  ),
                ),
                imageText == ''
                    ? Container()
                    : Container(
                        width: double.infinity,
                        height: 200,
                        margin: const EdgeInsets.symmetric(
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          image: DecorationImage(
                            image: NetworkImage(imageText),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                // --- Comment bar ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                  ),
                  margin: const EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${UserCredential.getBlogCommentCount(post.id)} ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const WidgetSpan(
                          child: FaIcon(
                            FontAwesomeIcons.comment,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getImage(String imgText) {
    return imgText.startsWith('http')
        ? NetworkImage(imgText)
        : AssetImage(imgText);
  }

  Container newPostCard(BuildContext context) {
    FocusNode focusNode = FocusNode();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Profile blogProfile =
                  UserCredential.getBlogProfile(UserCredential.userProfile.id)!;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlogProfile(blogProfile: blogProfile),
                ),
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.background,
              backgroundImage: getImage(
                UserCredential.getUserAvatar((UserCredential.userProfile.id)),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Write your feeling...',
                contentPadding: EdgeInsets.only(left: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              onTap: () {
                focusNode.unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBlogPost(isAddNew: true),
                  ),
                ).then((value) {
                  setState(() {});
                });
              },
            ),
          ),
          IconButton(
            onPressed: () {
              focusNode.unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddBlogPost(isAddNew: true),
                ),
              ).then((value) {
                setState(() {});
              });
            },
            icon: const Icon(EneftyIcons.gallery_add_outline),
          )
        ],
      ),
    );
  }

  InterstitialAd? interstitialAd;
  bool adReady = false;
  int adFailTimes = 0;

  loadInterstatialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.chitChatInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewBlogPost(post: clickPost!),
                  )).then((value) async {
                setState(() {});
                await API().getBlogPost();
                await API().getBlogComment();
                setState(() {});
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
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
                    builder: (context) => ViewBlogPost(post: clickPost!),
                  )).then((value) async {
                setState(() {});
                await API().getBlogPost();
                await API().getBlogComment();
                setState(() {});
              });
            },
            onAdDismissedFullScreenContent: (ad) {
              UserCredential.increasePoint();
              ad.dispose();
              interstitialAd?.dispose();
              setState(() {
                adReady = false;
              });
              AdHelper.runInterstitialAdTimer();
              startAdTimer();
            },
          );
          interstitialAd = ad;
          setState(() {
            adReady = true;
          });
          AdHelper.interstitialAdRequestTimes++;
          AdHelper.interstitialAdTimer?.cancel();
          adFailTimes = 0;
        },
        onAdFailedToLoad: (error) {
          setState(() {
            adReady = false;
          });
          AdHelper.interstitialAdRequestTimes++;
          AdHelper.runInterstitialAdTimer();
          adFailTimes++;
          if (adFailTimes < 3) {
            startAdTimer();
          }
        },
      ),
    );
  }

  Timer? _timer;
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

  Future<void> _onRefresh() async {
    await API().getBlogPost();
    await API().getBlogComment();
    setState(() {});
  }

  BannerAd? bannerAd;
  bool isBannaAdLoaded = false;
  void loadAd() {
    bannerAd = BannerAd(
      adUnitId: AdHelper.bottomBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannaAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    startAdTimer();
    getBlogPost();
    loadAd();
    super.initState();
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    _timer?.cancel();
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: myAppBar(context, adReady),
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: false,
      body: Stack(
        children: [
          isLoading
              ? const LoadingPage(
                  title: 'Chit-chat',
                  icon: EneftyIcons.message_square_outline,
                  info: 'Loading....',
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Column(
                    children: [
                      newPostCard(context),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              /*
                              // ---- story card section ----
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 8,
                                  left: 8,
                                ),
                                color: Theme.of(context).colorScheme.background,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        UserCredential.storyPhotos.length + 1,
                                    itemBuilder: (context, index) {
                                      return storyCard(context, index);
                                    },
                                  ),
                                ),
                              ),
                              */
                              UserCredential.blogPosts.isEmpty
                                  ? const SizedBox(
                                      width: double.infinity,
                                      height: 200,
                                      child: Center(
                                        child: Text('No Post'),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          UserCredential.blogPosts.length,
                                      itemBuilder: (context, index) => postCard(
                                          UserCredential.blogPosts[index]),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      isBannaAdLoaded
                          ? Container(
                              color: Theme.of(context).colorScheme.background,
                              width: double.infinity,
                              height: bannerAd!.size.height.toDouble(),
                              alignment: Alignment.center,
                              child: AdWidget(ad: bannerAd!),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
          isReloading
              ? const LoadingPage(
                  title: 'Chit-chat',
                  icon: EneftyIcons.message_square_outline,
                  info: 'Re-loading....',
                )
              : Container(),
        ],
      ),
    );
  }

  Widget storyCard(BuildContext context, int index) {
    return index == 0
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadStoryPhoto(),
                  )).then((value) {
                setState(() {});
              });
            },
            child: Container(
              width: 110,
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.shadow,
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: getImage(UserCredential.userProfile.userAvatar),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Icon(
                    EneftyIcons.gallery_add_outline,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const Text('Add Story'),
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewStoryPhoto(
                      storyPhoto: UserCredential.storyPhotos[index - 1]),
                ),
              ).then((value) {
                setState(() {});
              });
            },
            child: Container(
              width: 110,
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                border: Border.all(
                  color: Theme.of(context).colorScheme.shadow,
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
                image: UserCredential.storyPhotos[index - 1].photoUrl
                        .startsWith('http')
                    ? DecorationImage(
                        image: NetworkImage(
                            UserCredential.storyPhotos[index - 1].photoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: CircleAvatar(
                      backgroundImage: getImage(UserCredential.getUserAvatar(
                          UserCredential.storyPhotos[index - 1].userId)),
                    ),
                  ),
                  !UserCredential.storyPhotos[index - 1].photoUrl
                          .startsWith('http')
                      ? Center(
                          child: Text(
                            UserCredential.storyPhotos[index - 1].photoUrl,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    color: Theme.of(context).colorScheme.shadow,
                    child: Text(
                      UserCredential.getUserName(
                          UserCredential.storyPhotos[index - 1].userId),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
