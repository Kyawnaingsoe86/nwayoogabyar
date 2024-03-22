import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/article.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewArticle extends StatefulWidget {
  final Article article;
  const ViewArticle({super.key, required this.article});

  @override
  State<ViewArticle> createState() => _ViewArticleState();
}

class _ViewArticleState extends State<ViewArticle> {
  bool isMM = false;

  bool isReadyToLeave = false;
  Timer? _timer;

  BannerAd? bottomBannerAd;
  bool isBottomBannaAdLoaded = false;

  BannerAd? topBannerAd;
  bool isTopBannaAdLoaded = false;

  void loadAd() {
    topBannerAd = BannerAd(
      adUnitId: AdHelper.topBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
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

    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bottomBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBottomBannaAdLoaded = true;
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
    UserCredential.increasePoint();
    _timer = Timer(const Duration(seconds: 30), () {
      Fluttertoast.showToast(
        msg: "Point increased!!",
        backgroundColor: Theme.of(context).colorScheme.shadow,
      );
      setState(() {
        isReadyToLeave = true;
      });
    });
    loadAd();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    topBannerAd?.dispose();
    bottomBannerAd?.dispose();
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
          scrolledUnderElevation: 1,
          elevation: 1,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(EneftyIcons.arrow_left_3_outline),
          ),
          shadowColor: Theme.of(context).colorScheme.shadow,
          title: const Text('Detail'),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    if (isMM) {
                      isMM = false;
                    } else {
                      isMM = true;
                    }
                  });
                },
                icon: Icon(
                  EneftyIcons.translate_outline,
                  color: isMM
                      ? Theme.of(context).colorScheme.onBackground
                      : Theme.of(context).colorScheme.primary,
                )),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 250,
                      alignment: Alignment.bottomLeft,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onPrimary,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow,
                            offset: const Offset(1, 1),
                            blurRadius: 1,
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(widget.article.coverPhoto),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 80,
                        color: Colors.black45,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isMM
                              ? widget.article.titleMM
                              : widget.article.titleEN,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      padding: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2)),
                      ),
                      child: Text(
                        'Author - ${widget.article.author}',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        'Category - ${widget.article.category}',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      padding: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                      ),
                      child: Linkify(
                        onOpen: (link) async {
                          if (!await launchUrl(Uri.parse(link.url),
                              mode: LaunchMode.externalApplication)) {
                            throw Exception('Could not launch ${link.url}');
                          }
                        },
                        text: 'Source - ${widget.article.source}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    isTopBannaAdLoaded && !isMM
                        ? Container(
                            color: Theme.of(context).colorScheme.background,
                            width: topBannerAd!.size.width.toDouble(),
                            height: topBannerAd!.size.height.toDouble(),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: AdWidget(ad: topBannerAd!),
                          )
                        : const SizedBox(),
                    isMM
                        ? const SizedBox()
                        : Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            child: const Text(
                              'Translation is made by using Google Translate',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SelectableLinkify(
                        text: isMM
                            ? widget.article.contentMM
                            : widget.article.contentEN,
                        onOpen: (link) async {
                          if (!await launchUrl(Uri.parse(link.url),
                              mode: LaunchMode.externalApplication)) {
                            throw Exception('Could not launch ${link.url}');
                          }
                        },
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: isBottomBannaAdLoaded && !isMM
            ? Container(
                color: Theme.of(context).colorScheme.background,
                width: bottomBannerAd!.size.width.toDouble(),
                height: bottomBannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: AdWidget(ad: bottomBannerAd!),
              )
            : const SizedBox(),
      ),
    );
  }
}
