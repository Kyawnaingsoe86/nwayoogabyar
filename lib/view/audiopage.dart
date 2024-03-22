import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/audiofile.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/appdrawer.dart';
import 'package:nwayoogabyar/view/audioplayer.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:nwayoogabyar/view/myappbar.dart';
import 'package:nwayoogabyar/view/viewallaudio.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  int remainedPoints = 0;
  bool isLoading = true;
  bool isReloading = false;

  getAudios() async {
    setState(() {
      isLoading = true;
    });
    if (UserCredential.audios.isEmpty) {
      try {
        await API().getAudioFile();
        setState(() {
          isLoading = false;
          isReloading = false;
        });
      } on Exception catch (e) {
        setState(() {
          isLoading = false;
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
                      Timer(const Duration(seconds: 20), () {
                        getAudios();
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
        isLoading = false;
        isReloading = false;
      });
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

  bool adReady = false;
  InterstitialAd? interstitialAd;
  AudioFile? selectedAudio;
  int adFailTimes = 0;

  loadInterstatialAd() {
    if (AdHelper.interstitialAdRequestTimes >=
        AdHelper.maxAdRequestTimesPerHour) {
      return;
    } else {
      AdHelper.interstitialAdRequestTimes++;
      InterstitialAd.load(
        adUnitId: AdHelper.audioInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
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
                    builder: (context) =>
                        MyAudioPlayer(audioFile: selectedAudio!),
                  ),
                ).then((value) {
                  setState(() {});
                });
              },
              onAdShowedFullScreenContent: (ad) {},
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
                    builder: (context) =>
                        MyAudioPlayer(audioFile: selectedAudio!),
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

  Timer? _timer;
  startAdTimer() {
    _timer?.cancel();
    if (adReady) return;
    _timer = Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
      loadInterstatialAd();
    });
  }

  Widget audioListCard(AudioFile audio) {
    return GestureDetector(
      onTap: () {
        selectedAudio = audio;
        if (UserCredential.isClicked(audio.audioId)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyAudioPlayer(audioFile: audio),
            ),
          ).then((value) {
            setState(() {});
            startAdTimer();
          });
        } else {
          UserCredential.setClickedId(audio.audioId);
          adReady
              ? interstitialAd!.show()
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyAudioPlayer(audioFile: audio),
                  ),
                ).then((value) {
                  setState(() {});
                  startAdTimer();
                });
        }
      },
      child: Container(
        width: double.infinity,
        height: 100,
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          border: Border.all(
            color: UserCredential.isClicked(audio.audioId)
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.background,
            width: 4,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Theme.of(context).colorScheme.shadow,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: audio.coverPhoto == ''
                    ? const DecorationImage(
                        image: AssetImage('./lib/image/audio.png'),
                      )
                    : DecorationImage(
                        image: NetworkImage(audio.coverPhoto!),
                        fit: BoxFit.cover,
                      ),
              ),
              child: Container(
                width: double.infinity,
                height: 40,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.shadow,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  audio.audioTitleMM,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    alignment: Alignment.topLeft,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Text(
                      audio.audioTitleEN,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      audio.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FaIcon(FontAwesomeIcons.clock, size: 10),
                        const Text(
                          ' Duration: ',
                          style: TextStyle(fontSize: 9),
                        ),
                        Text(
                          audio.duration,
                          style: const TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      'Play Count: ${audio.playCount}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(3),
                          ),
                        ),
                        child: Text(
                          audio.audioCategory,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(3),
                          ),
                        ),
                        child: Text(
                          audio.audioGenre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await getAudios();
  }

  @override
  void initState() {
    getAudios();
    loadAd();
    loadInterstatialAd();
    super.initState();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
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
                  title: 'Podcast',
                  icon: EneftyIcons.audio_square_outline,
                  info: 'Loading...',
                )
              : Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: Column(
                        children: [
                          // --- Category List ---
                          Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: UserCredential.audioCategories.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewAllAudio(
                                              header: UserCredential
                                                  .audioCategories[index]),
                                        )).then((value) {
                                      startAdTimer();
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                    ),
                                    child: Text(
                                      UserCredential.audioCategories[index]
                                          .toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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

                          // --- Recent Title ---
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            width: double.infinity,
                            child: Text(
                              "Recent Upload".toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          // --- Recent List ---
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: 8,
                              itemBuilder: (context, index) {
                                return audioListCard(
                                    UserCredential.audios[index]);
                              },
                            ),
                          ),

                          // --- Bottom Ad ---
                          isBannaAdLoaded
                              ? Container(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  width: double.infinity,
                                  height: bannerAd!.size.height.toDouble(),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: AdWidget(ad: bannerAd!),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    isReloading
                        ? const LoadingPage(
                            title: 'Podcast',
                            icon: EneftyIcons.audio_square_outline,
                            info: 'Re-Loading...',
                          )
                        : Container(),
                  ],
                ),
        ],
      ),
    );
  }
}
