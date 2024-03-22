import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/model/post.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/fullimageview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/credential.dart';

class ViewPost extends StatefulWidget {
  final Post post;
  const ViewPost({super.key, required this.post});

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  bool isLoading = true;
  bool isMM = false;

  bool isSupported = false;
  bool isReadyToLeave = false;
  bool isLiked = false;
  Timer? _timer;

  BannerAd? topBannerAd;
  bool isTopBannerAdLoaded = false;

  BannerAd? bottomBannerAd;
  bool isBottomBannerAdLoaded = false;

  void loadAd() {
    topBannerAd = BannerAd(
      adUnitId: AdHelper.topBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isTopBannerAdLoaded = true;
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

    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bottomBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBottomBannerAdLoaded = true;
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
    loadAd();
    isLiked = widget.post.likedUserId.contains(UserCredential.userProfile.id);
    _timer = Timer(const Duration(seconds: 30), () {
      Fluttertoast.showToast(
        msg: "Point increased!!",
        backgroundColor: Theme.of(context).colorScheme.shadow,
      );
      setState(() {
        isReadyToLeave = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (isLiked !=
        widget.post.likedUserId.contains(UserCredential.userProfile.id)) {
      UserCredential.editPostLikedIds(widget.post.postId, isLiked);
    }

    topBannerAd?.dispose();
    bottomBannerAd?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isReadyToLeave,
      onPopInvoked: (didPop) {
        if (!isReadyToLeave) {
          Fluttertoast.showToast(
            msg: "Please wait for increasing point.",
            backgroundColor: Theme.of(context).colorScheme.shadow,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
          scrolledUnderElevation: 0,
          elevation: 0,
          shadowColor: Theme.of(context).colorScheme.shadow,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(EneftyIcons.arrow_left_3_outline),
          ),
          title: const Text('Detail'),
          actions: [
            IconButton(
              onPressed: isReadyToLeave
                  ? () {
                      setState(() {
                        if (isMM) {
                          isMM = false;
                        } else {
                          isMM = true;
                        }
                      });
                    }
                  : () {
                      Fluttertoast.showToast(
                        msg: "Please wait for increasing point.",
                        backgroundColor: Theme.of(context).colorScheme.shadow,
                      );
                    },
              icon: isMM
                  ? const Icon(
                      Icons.g_translate,
                      color: Colors.amber,
                    )
                  : const Icon(Icons.g_translate),
            ),
          ],
        ),
        body: Stack(
          alignment: const Alignment(1, 0.9),
          children: [
            widget.post.mmDescription.startsWith('http')
                ? Column(
                    children: [
                      isTopBannerAdLoaded
                          ? Container(
                              color: Theme.of(context).colorScheme.background,
                              width: topBannerAd!.size.width.toDouble(),
                              height: topBannerAd!.size.height.toDouble(),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: AdWidget(ad: topBannerAd!),
                            )
                          : const SizedBox(),
                      Expanded(
                        child: SfPdfViewer.network(widget.post.mmDescription),
                      ),
                      widget.post.credit == ''
                          ? const SizedBox()
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  border: const Border(
                                      top: BorderSide(color: Colors.black12),
                                      bottom:
                                          BorderSide(color: Colors.black12))),
                              child: Linkify(
                                onOpen: (link) async {
                                  if (!await launchUrl(Uri.parse(link.url),
                                      mode: LaunchMode.externalApplication)) {
                                    throw Exception(
                                        'Could not launch ${link.url}');
                                  }
                                },
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: widget.post.credit,
                              ),
                            ),
                    ],
                  )
                : Column(
                    children: [
                      isTopBannerAdLoaded && !isMM
                          ? Container(
                              color: Theme.of(context).colorScheme.background,
                              width: topBannerAd!.size.width.toDouble(),
                              height: topBannerAd!.size.height.toDouble(),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: AdWidget(ad: topBannerAd!),
                            )
                          : const SizedBox(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullImageView(
                                            imgUrl: widget.post.coverPhotoUrl),
                                      ));
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  alignment: Alignment.bottomLeft,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      width: 5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .shadow,
                                        offset: const Offset(1, 1),
                                        blurRadius: 1,
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          widget.post.coverPhotoUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 70,
                                    color: Theme.of(context).colorScheme.shadow,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      isMM
                                          ? widget.post.mmTitle
                                          : widget.post.enTitle,
                                      textAlign: TextAlign.left,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.shadow,
                                thickness: 0.4,
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  top: 5,
                                ),
                                child: Text(
                                  'Author : ${widget.post.author}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  'Category : ${widget.post.category}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              widget.post.credit == ''
                                  ? Container()
                                  : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        bottom: 5,
                                      ),
                                      child: Linkify(
                                        onOpen: (link) async {
                                          if (!await launchUrl(
                                              Uri.parse(link.url),
                                              mode: LaunchMode
                                                  .externalApplication)) {
                                            throw Exception(
                                                'Could not launch ${link.url}');
                                          }
                                        },
                                        text: 'Credit : ${widget.post.credit}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                              Divider(
                                color: Theme.of(context).colorScheme.shadow,
                                thickness: 0.4,
                              ),
                              isMM
                                  ? Container()
                                  : Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(
                                        left: 5,
                                        top: 5,
                                      ),
                                      child: Text(
                                        'Translation is made by using google translate.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .shadow,
                                        ),
                                      ),
                                    ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  bottom: 20,
                                ),
                                child: Linkify(
                                  onOpen: (link) async {
                                    if (!await launchUrl(Uri.parse(link.url),
                                        mode: LaunchMode.externalApplication)) {
                                      throw Exception(
                                          'Could not launch ${link.url}');
                                    }
                                  },
                                  text: isMM
                                      ? widget.post.mmDescription
                                      : widget.post.enDescription,
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    height: 1.8,
                                  ),
                                ),
                              ),
                              isBottomBannerAdLoaded && !isMM
                                  ? Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      width:
                                          bottomBannerAd!.size.width.toDouble(),
                                      height: bottomBannerAd!.size.height
                                          .toDouble(),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: AdWidget(ad: bottomBannerAd!),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            Container(
              width: 40,
              height: 100,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      var result = 0;
                      if (isSupported) {
                      } else {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: DesignProvider.getDialogBoxShape(10),
                            title: const Text('Support'),
                            content: const Text(
                                'For your support, We will deduct 5 stars from your account. Are you sure to support?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  result = UserCredential.deductPoints(5);
                                  Navigator.pop(context);
                                },
                                child: const Text('Support'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (result == 1 && mounted) {
                        UserCredential.addPostSupport(widget.post.postId);
                        setState(() {
                          isSupported = true;
                        });
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  shape: DesignProvider.getDialogBoxShape(10),
                                  title: const Text('Thank you!!'),
                                  content: const Text(
                                      ' 💌 Thank you for your support! 💌 '),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('😍😍😍'),
                                    ),
                                  ],
                                ));
                      } else if (result == -1 && mounted) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  shape: DesignProvider.getDialogBoxShape(10),
                                  title: const Text('Not Enought Star'),
                                  content: const Text(
                                      ' 🌟 Sorry!, you have no enough star to support. Please read more poems to get stars. 🌟'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('🌟🌟🌟'),
                                    ),
                                  ],
                                ));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.shadow,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20),
                        ),
                      ),
                      child: isSupported
                          ? Icon(
                              EneftyIcons.star_2_bold,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : Icon(
                              EneftyIcons.star_2_outline,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.shadow,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20),
                        ),
                      ),
                      child: isLiked
                          ? Icon(
                              EneftyIcons.like_tag_bold,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : Icon(
                              EneftyIcons.like_tag_outline,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reactBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 30),
        GestureDetector(
          child: RichText(
            text: TextSpan(
              text: '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              children: [
                WidgetSpan(
                  child: Icon(
                    isSupported ? Icons.star : Icons.star_border,
                  ),
                ),
                TextSpan(text: isSupported ? " Supported" : ' Support'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  getProfileImage(String imgLink) {
    return imgLink.startsWith('http')
        ? NetworkImage(imgLink)
        : AssetImage(imgLink);
  }
}
