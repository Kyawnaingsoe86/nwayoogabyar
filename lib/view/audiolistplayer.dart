import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/audiofile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AudioListPlayer extends StatefulWidget {
  final List<AudioFile> audioFiles;

  const AudioListPlayer({
    super.key,
    required this.audioFiles,
  });

  @override
  State<AudioListPlayer> createState() => _AudioListPlayerState();
}

class _AudioListPlayerState extends State<AudioListPlayer> {
  AudioPlayer player = AudioPlayer();
  Timer? _timer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isReadyToBack = false;
  bool isRepeat = false;
  int playingIndex = 0;

  playAudio(int index) {
    player.play(UrlSource(widget.audioFiles[index].audioUrl));
  }

  String formatDurationInHhMmSs(Duration duration) {
    final hh = (duration.inHours).toString().padLeft(2, '0');
    final mm = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hh:$mm:$ss';
  }

  BannerAd? bottomBannerAd;
  bool isBottomAdLoaded = false;

  void loadBottomAd() {
    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bottomBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isBottomAdLoaded = true;
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

  BannerAd? topBannerAd;
  bool isTopAdLoaded = false;

  void loadTopAd() {
    topBannerAd = BannerAd(
      adUnitId: AdHelper.audioBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isTopAdLoaded = true;
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

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    UserCredential.increasePoint();

    _timer = Timer(const Duration(seconds: 30), () {
      API().increastAudioPlayCount(widget.audioFiles[playingIndex].audioId);
      Fluttertoast.showToast(
        msg: "Point increased!!",
        backgroundColor: Theme.of(context).colorScheme.shadow,
      );
      setState(() {
        isReadyToBack = true;
      });
    });

    loadTopAd();
    loadBottomAd();
    playAudio(playingIndex);
    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
      if (state == PlayerState.completed) {
        if (playingIndex < widget.audioFiles.length - 1) {
          playingIndex = playingIndex + 1;
          playAudio(playingIndex);
        } else {
          WakelockPlus.disable();
        }
      }
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });

      if (widget.audioFiles[playingIndex].duration == 'unknow') {
        String audioDuration = formatDurationInHhMmSs(duration);
        API().setAudioDuration(
            widget.audioFiles[playingIndex].audioId, "'$audioDuration");
      }
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    player.dispose();
    WakelockPlus.disable();
    topBannerAd?.dispose();
    bottomBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isReadyToBack,
      onPopInvoked: (didPop) {
        if (isReadyToBack) {
          return;
        } else {
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
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(EneftyIcons.arrow_left_3_outline),
          ),
          title: const Text('Audio Player'),
        ),
        body: Column(
          children: [
            // ---- info block ---
            Container(
              width: double.infinity,
              height: 120,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    spreadRadius: 1,
                    blurRadius: 1,
                  )
                ],
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                      image: widget.audioFiles[playingIndex].coverPhoto == ''
                          ? const DecorationImage(
                              image: AssetImage('./lib/image/playing.gif'),
                              fit: BoxFit.contain,
                            )
                          : DecorationImage(
                              image: NetworkImage(
                                  widget.audioFiles[playingIndex].coverPhoto!),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            widget.audioFiles[playingIndex].audioTitleEN,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            widget.audioFiles[playingIndex].audioTitleMM,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            widget.audioFiles[playingIndex].artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(right: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.audioFiles[playingIndex].audioGenre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${formatDurationInHhMmSs(position)} / ${formatDurationInHhMmSs(duration)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            isTopAdLoaded
                ? Container(
                    width: double.infinity,
                    height: topBannerAd!.size.height.toDouble(),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).colorScheme.shadow,
                            spreadRadius: 0,
                            blurRadius: 2,
                            offset: const Offset(0, 1))
                      ],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: AdWidget(ad: topBannerAd!),
                  )
                : const SizedBox(),

            // --- control bar ---
            Container(
              margin: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      spreadRadius: 0,
                      blurRadius: 2,
                      offset: const Offset(0, 1))
                ],
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (playingIndex > 0) {
                          playingIndex = playingIndex - 1;
                          playAudio(playingIndex);
                        }
                      },
                      icon: Icon(
                        Icons.skip_previous,
                        shadows: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow,
                            blurRadius: 10,
                            spreadRadius: 2,
                            //offset: const Offset(1, 1),
                          )
                        ],
                      ),
                      iconSize: 25,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    IconButton(
                      onPressed: () {
                        if (isPlaying) {
                          player.pause();
                        } else {
                          playAudio(playingIndex);
                        }
                      },
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        shadows: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow,
                            blurRadius: 10,
                            spreadRadius: 2,
                            //offset: const Offset(1, 1),
                          )
                        ],
                      ),
                      iconSize: 40,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    IconButton(
                      onPressed: () {
                        if (playingIndex < widget.audioFiles.length - 1) {
                          playingIndex++;
                          playAudio(playingIndex);
                        }
                      },
                      icon: Icon(
                        Icons.skip_next,
                        shadows: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow,
                            blurRadius: 10,
                            spreadRadius: 2,
                            //offset: const Offset(1, 1),
                          )
                        ],
                      ),
                      iconSize: 25,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ),

            // --- audio list view ----
            Expanded(
              child: Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.audioFiles.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            playingIndex = index;
                          });
                          playAudio(index);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              border: index == playingIndex
                                  ? Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow,
                                  blurRadius: 0.5,
                                )
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.audioFiles[index].audioTitleEN} (${widget.audioFiles[index].artist})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              playingIndex == index
                                  ? SizedBox(
                                      width: 20,
                                      child: Image.asset(
                                          './lib/image/playing.gif'),
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
        bottomNavigationBar: isBottomAdLoaded
            ? Container(
                color: Theme.of(context).colorScheme.background,
                width: bottomBannerAd!.size.width.toDouble(),
                height: bottomBannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: AdWidget(ad: bottomBannerAd!),
              )
            : null,
      ),
    );
  }
}
