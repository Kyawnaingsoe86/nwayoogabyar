import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/videofile.dart';
import 'package:nwayoogabyar/view/appdrawer.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:nwayoogabyar/view/myappbar.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  bool adReady = false;
  bool isLoading = true;
  bool isReloading = false;
  int selectedIndex = 0;

  List<VideoFile> videos = [];

  loadData() async {
    try {
      if (UserCredential.videos.isEmpty) {
        await API().getVideoFile();
      }
      videos = UserCredential.videos;
      setState(() {
        videos.shuffle();
        isLoading = false;
        isReloading = false;
      });
      await loadVideo(videos[0].videoLink);
      _controller.play();
    } on Exception catch (e) {
      setState(() {
        isReloading = true;
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Server does not response! Try again."),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Timer(const Duration(seconds: 10), () {
                      loadData();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }

  late VideoPlayerController _controller;
  bool videoLoading = true;

  loadVideo(String videoUrl) async {
    setState(() {
      videoLoading = true;
    });
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    await _controller.initialize();
    setState(() {
      videoLoading = false;
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
        adUnitId: AdHelper.chitChatInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                loadVideo(videos[selectedIndex].videoLink);
                UserCredential.increasePoint();
                setState(() {});
              },
              onAdDismissedFullScreenContent: (ad) {
                _controller.play();
                ad.dispose();
                interstitialAd?.dispose();
                setState(() {
                  adReady = false;
                });
                AdHelper.runInterstitialAdTimer();
                startAdTimer();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _controller.play();
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
            AdHelper.interstitialAdTimer?.cancel();
            adFailTimes = 0;
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

  Timer? _timer;
  int adTimer = 0;
  startAdTimer() {
    _timer?.cancel();
    if (adReady) return;
    adTimer = AdHelper.interstitialAdCounter;
    _timer = Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
      loadInterstatialAd();
    });
  }

  BannerAd? bannerAd;
  bool isBannaAdLoaded = false;

  void loadAd() {
    bannerAd = BannerAd(
      adUnitId: AdHelper.topBannerAdUnitId,
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

  Timer? _pointTimer;
  increasePoint() {
    _pointTimer = Timer(const Duration(seconds: 30), () {
      UserCredential.increasePoint();
      setState(() {});
    });
  }

  @override
  void initState() {
    WakelockPlus.enable();
    loadData();
    loadInterstatialAd();
    loadAd();
    increasePoint();
    super.initState();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _controller.dispose();
    _timer?.cancel();
    bannerAd?.dispose();
    _pointTimer?.cancel();
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
                  title: 'Clip',
                  icon: EneftyIcons.video_square_outline,
                  info: 'Loading...',
                )
              : PageView.builder(
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) async {
                    _controller.pause();
                    _controller.dispose();

                    if (adReady) {
                      selectedIndex = index;
                      interstitialAd?.show();
                    } else {
                      await loadVideo(videos[index].videoLink);
                      _controller.play();
                    }
                  },
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        videoLoading
                            ? Container(
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              )
                            : GestureDetector(
                                onTap: () {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                },
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: <Widget>[
                                    VideoPlayer(_controller),
                                    VideoProgressIndicator(_controller,
                                        allowScrubbing: true),
                                  ],
                                ),
                              ),
                        !_controller.value.isPlaying
                            ? GestureDetector(
                                onTap: () {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                },
                                child: Container(
                                  color: Theme.of(context).colorScheme.shadow,
                                  child: const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.circlePlay,
                                      size: 80,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    );
                  },
                ),
          isReloading
              ? const LoadingPage(
                  title: 'Clip',
                  icon: EneftyIcons.video_square_outline,
                  info: 'Re-Loading...',
                )
              : isBannaAdLoaded
                  ? Container(
                      color: Theme.of(context).colorScheme.shadow,
                      width: double.infinity,
                      height: bannerAd!.size.height.toDouble(),
                      alignment: Alignment.center,
                      child: AdWidget(ad: bannerAd!),
                    )
                  : Container(
                      height: 50,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.shadow,
                    ),
        ],
      ),
    );
  }
}
