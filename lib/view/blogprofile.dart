import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/controller/dateformatter.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/blogpost.dart';
import 'package:nwayoogabyar/model/profile.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/changeheader.dart';
import 'package:nwayoogabyar/view/viewblogpost.dart';

class BlogProfile extends StatefulWidget {
  final Profile blogProfile;
  const BlogProfile({
    super.key,
    required this.blogProfile,
  });

  @override
  State<BlogProfile> createState() => _BlogProfileState();
}

class _BlogProfileState extends State<BlogProfile> {
  List<BlogPost> userBlogPosts = [];
  BlogPost? clickPost;
  String headerImg = "";

  getUserPost() {
    headerImg = widget.blogProfile.headerImg;
    userBlogPosts = UserCredential.getUserBlogPost(widget.blogProfile.id);
  }

  Widget blogPostCard(BlogPost post) {
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
      color: Theme.of(context).colorScheme.background,
      margin: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          if (adReady) {
            clickPost = post;
            interstitialAd!.show();
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewBlogPost(post: post),
                )).then((value) {
              getUserPost();
              interstitialAd?.dispose();
              startAdTimer();
              API().getBlogPost();
              API().getBlogComment();
            });
          }
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            left: 5,
            right: 5,
            bottom: 15,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
          ),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      getAvatarImg(UserCredential.getUserAvatar(post.userId)),
                ),
                title: Text(
                  UserCredential.getUserName(post.userId),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  DateFormatter.getDateTimeFromDouble(
                    double.parse(post.timestamp),
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                contentPadding: const EdgeInsets.all(0),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  postText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.6,
                  ),
                ),
              ),
              imageText == ""
                  ? const SizedBox()
                  : Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        image: DecorationImage(
                          image: NetworkImage(imageText),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.shadow,
                      width: 0.4,
                    ),
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.shadow,
                      width: 0.4,
                    ),
                  ),
                ),
                child: Text(
                    "${UserCredential.getBlogCommentCount(post.id)} Comments"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InterstitialAd? interstitialAd;
  int adLoadTime = 0;
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
                  )).then((value) {
                setState(() {});

                API().getBlogPost();
                API().getBlogComment();
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewBlogPost(post: clickPost!),
                  )).then((value) {
                setState(() {});

                API().getBlogPost();
                API().getBlogComment();
              });
              ad.dispose();
              interstitialAd?.dispose();
              setState(() {
                adReady = false;
              });

              AdHelper.runInterstitialAdTimer();
              startAdTimer();
            },
            onAdDismissedFullScreenContent: (ad) {
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

  @override
  void initState() {
    startAdTimer();
    getUserPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
        title: Text(
          "${widget.blogProfile.userName}'s Timeline",
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (widget.blogProfile.id == UserCredential.userProfile.id) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeHeader(
                          headerImg: headerImg,
                        ),
                      )).then((value) {
                    setState(() {
                      headerImg = value;
                    });
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 30,
                ),
                margin: const EdgeInsets.only(bottom: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  image: DecorationImage(
                    image: AssetImage(headerImg),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      backgroundImage:
                          getAvatarImg(widget.blogProfile.userAvatar),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        widget.blogProfile.userName,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            shadows: [
                              BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow,
                                  blurRadius: 5,
                                  spreadRadius: 10,
                                  offset: const Offset(1, 2))
                            ]),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        GlobalKey<FormState> formKey = GlobalKey<FormState>();
                        TextEditingController bioText = TextEditingController();
                        if (widget.blogProfile.id ==
                            UserCredential.userProfile.id) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: DesignProvider.getDialogBoxShape(10),
                              title: const Text(
                                'Edit bio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Form(
                                key: formKey,
                                child: TextFormField(
                                  controller: bioText
                                    ..text = widget.blogProfile.userBio,
                                  minLines: 3,
                                  maxLines: 3,
                                  maxLength: 160,
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Enter bio status.';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      widget.blogProfile.userBio = bioText.text;
                                      UserCredential.changeBio(bioText.text);
                                      setState(() {});
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 10,
                        ),
                        margin: const EdgeInsets.only(top: 10),
                        color: Theme.of(context).colorScheme.shadow,
                        child: Text(
                          widget.blogProfile.userBio,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            height: 1.5,
                            fontFamily: "Z01-Umoe002",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            userBlogPosts.isEmpty
                ? Container(
                    width: double.infinity,
                    height: 100,
                    alignment: Alignment.center,
                    child: const Text('No post'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    itemCount: userBlogPosts.length,
                    itemBuilder: (context, index) {
                      return blogPostCard(userBlogPosts[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  getAvatarImg(String imgLink) {
    return imgLink.startsWith('http')
        ? NetworkImage(imgLink)
        : AssetImage(imgLink);
  }
}
