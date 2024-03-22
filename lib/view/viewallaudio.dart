import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/audiofile.dart';
import 'package:nwayoogabyar/view/audiolistplayer.dart';
import 'package:nwayoogabyar/view/audioplayer.dart';
import 'package:nwayoogabyar/view/loading.dart';

class ViewAllAudio extends StatefulWidget {
  final String header;
  const ViewAllAudio({super.key, required this.header});

  @override
  State<ViewAllAudio> createState() => _ViewAllAudioState();
}

class _ViewAllAudioState extends State<ViewAllAudio> {
  List<AudioFile> audios = [];
  List<AudioFile> selectedAudios = [];
  List<String> genres = [];
  List<String> artists = [];
  int selectedIndex = 0;
  bool byArtist = false;
  bool isListView = false;
  bool reload = false;
  bool isLoading = true;
  bool isSelectView = false;

  loadAudios() async {
    audios = [];
    setState(() {
      isLoading = true;
    });
    Set<String> genreTemp = {};
    Set<String> artistTemp = {};
    for (int i = 0; i < UserCredential.audios.length; i++) {
      if (UserCredential.audios[i].audioCategory == widget.header) {
        audios.add(UserCredential.audios[i]);
        genreTemp.add(UserCredential.audios[i].audioGenre);
        artistTemp.add(UserCredential.audios[i].artist);
      }
    }
    genres = genreTemp.toList();
    artists = artistTemp.toList();
    loadSelectedAudios(selectedIndex);

    setState(() {
      audios;
      isLoading = false;
    });
  }

  loadSelectedAudios(int index) {
    selectedAudios = [];
    for (int i = 0; i < audios.length; i++) {
      if (byArtist) {
        if (audios[i].artist == artists[index]) {
          selectedAudios.add(audios[i]);
        }
      } else {
        if (audios[i].audioGenre == genres[index]) {
          selectedAudios.add(audios[i]);
        }
      }
    }
    setState(() {
      selectedAudios;
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
                runAdTimer();
                if (selectedPlayAudios.isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MyAudioPlayer(audioFile: selectedAudio!),
                    ),
                  ).then((value) {
                    setState(() {});
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioListPlayer(
                        audioFiles: selectedPlayAudios,
                      ),
                    ),
                  ).then((value) {
                    setState(() {
                      isSelectView = false;
                      selectedPlayAudios = [];
                      selectedId = [];
                    });
                  });
                }
              },
              onAdShowedFullScreenContent: (ad) {},
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                interstitialAd?.dispose();
                setState(() {
                  adReady = false;
                });

                AdHelper.runInterstitialAdTimer();
                runAdTimer();
                if (selectedPlayAudios.isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MyAudioPlayer(audioFile: selectedAudio!),
                    ),
                  ).then((value) {
                    setState(() {});
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioListPlayer(
                        audioFiles: selectedPlayAudios,
                      ),
                    ),
                  ).then((value) {
                    setState(() {
                      isSelectView = false;
                      selectedPlayAudios = [];
                      selectedId = [];
                    });
                  });
                }
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
              runAdTimer();
            }
          },
        ),
      );
    }
  }

  Widget audioGridCard(AudioFile audio) {
    return GestureDetector(
      onTap: () {
        selectedAudio = audio;
        UserCredential.isClicked(audio.audioId)
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyAudioPlayer(audioFile: audio),
                ),
              ).then((value) {
                if (!adReady) runAdTimer();
                setState(() {});
              })
            : adReady
                ? interstitialAd!.show()
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyAudioPlayer(audioFile: audio),
                    ),
                  ).then((value) {
                    if (!adReady) runAdTimer();
                    setState(() {});
                  });
      },
      child: Container(
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
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
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
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              child: Text(
                audio.audioTitleEN,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
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
                  fontSize: 9,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                right: 5,
                top: 3,
                bottom: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FaIcon(FontAwesomeIcons.clock, size: 10),
                      Text(
                        ' ${audio.duration}',
                        style: const TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                  Text(
                    '${audio.playCount}',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
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

  Widget audioListCard(AudioFile audio) {
    return GestureDetector(
      onTap: () {
        selectedAudio = audio;
        UserCredential.isClicked(audio.audioId)
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyAudioPlayer(audioFile: audio),
                ),
              ).then((value) {
                if (!adReady) runAdTimer();
                setState(() {});
              })
            : adReady
                ? interstitialAd!.show()
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyAudioPlayer(audioFile: audio),
                    ),
                  ).then((value) {
                    if (!adReady) runAdTimer();
                    setState(() {});
                  });
      },
      child: Container(
        width: double.infinity,
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
              height: 100,
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

  List<AudioFile> selectedPlayAudios = [];
  List<String> selectedId = [];

  Widget selectableAudioListCard(AudioFile audio) {
    return GestureDetector(
      onTap: () {
        if (!selectedId.contains(audio.audioId)) {
          selectedPlayAudios.add(audio);
          selectedId.add(audio.audioId);
        } else {
          selectedPlayAudios
              .removeWhere((element) => element.audioId == audio.audioId);
          selectedId.remove(audio.audioId);
        }

        setState(() {
          selectedPlayAudios;
          selectedId;
        });
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
            ),
            Container(
              width: 20,
              margin: const EdgeInsets.only(right: 8, bottom: 5),
              alignment: Alignment.bottomRight,
              child: Icon(
                selectedId.contains(audio.audioId)
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Timer? _timer;

  runAdTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: AdHelper.interstitialAdCounter), () {
      loadInterstatialAd();
    });
  }

  @override
  void initState() {
    runAdTimer();
    loadAd();
    loadAudios();
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
      floatingActionButton: selectedId.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                if (adReady) {
                  interstitialAd?.show();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioListPlayer(
                        audioFiles: selectedPlayAudios,
                      ),
                    ),
                  ).then((value) {
                    runAdTimer();
                    setState(() {
                      isSelectView = false;
                      selectedPlayAudios = [];
                      selectedId = [];
                    });
                  });
                }
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Play Selected Audios'),
            ),
      body: Column(
        children: [
          // --- view change icons ---
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 40,
                  height: 30,
                  child: GestureDetector(
                    onTap: () {
                      isSelectView = !isSelectView;
                      if (!isSelectView) {
                        selectedPlayAudios = [];
                        selectedId = [];
                      }
                      loadSelectedAudios(0);
                      setState(() {
                        selectedIndex = 0;
                      });
                    },
                    child: Icon(
                      isSelectView
                          ? EneftyIcons.element_plus_bold
                          : EneftyIcons.element_plus_outline,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 40,
                  height: 30,
                  child: GestureDetector(
                    onTap: () {
                      byArtist = !byArtist;
                      loadSelectedAudios(0);
                      setState(() {
                        selectedIndex = 0;
                      });
                    },
                    child: Icon(
                      byArtist
                          ? EneftyIcons.personalcard_bold
                          : EneftyIcons.music_dashboard_bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 30,
                  child: GestureDetector(
                    onTap: () {
                      isListView = !isListView;
                      setState(() {});
                    },
                    child: Icon(
                      isListView
                          ? EneftyIcons.row_vertical_bold
                          : EneftyIcons.element_3_bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //---- Category Bar ----
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: byArtist ? artists.length : genres.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    loadSelectedAudios(index);
                  },
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      color: index == selectedIndex
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.background,
                      width: 5,
                    ))),
                    child: Text(
                      byArtist
                          ? artists[index].toUpperCase()
                          : genres[index].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          //---- Audio List -----
          Expanded(
            child: isLoading
                ? const LoadingPage(
                    title: 'Podcast',
                    icon: EneftyIcons.audio_square_outline,
                    info: 'Loading...',
                  )
                : isSelectView
                    ? Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: ListView.builder(
                          itemCount: selectedAudios.length,
                          itemBuilder: (context, index) =>
                              selectableAudioListCard(selectedAudios[index]),
                        ),
                      )
                    : isListView
                        ? Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: ListView.builder(
                              itemCount: selectedAudios.length,
                              itemBuilder: (context, index) =>
                                  audioListCard(selectedAudios[index]),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: selectedAudios.length,
                              itemBuilder: (context, index) =>
                                  audioGridCard(selectedAudios[index]),
                            ),
                          ),
          ),
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
