import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/audiofile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyAudioPlayer extends StatefulWidget {
  final AudioFile audioFile;

  const MyAudioPlayer({
    super.key,
    required this.audioFile,
  });

  @override
  State<MyAudioPlayer> createState() => _MyAudioPlayerState();
}

class _MyAudioPlayerState extends State<MyAudioPlayer> {
  AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isReadyToBack = false;
  bool isRepeat = false;

  playAudio() {
    player.play(UrlSource(widget.audioFile.audioUrl));
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
      size: AdSize.mediumRectangle,
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

  List<int> playList = [];
  int currentTrack = 0;
  bool existPlaylist = false;
  bool isFirstTrack = true;
  bool isLastTrack = true;
  Timer? _timer;

  getPlaylist() {
    playList = [];
    if (widget.audioFile.playlist != '') {
      setState(() {
        existPlaylist = true;
      });
      List temp =
          widget.audioFile.playlist!.replaceAll(' ', '').split(',').toList();
      for (var element in temp) {
        playList.add(int.parse(element));
      }
      currentTrack = 0;
      isFirstTrack = true;
      isLastTrack = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    UserCredential.increasePoint();
    _timer = Timer(const Duration(seconds: 30), () {
      API().increastAudioPlayCount(widget.audioFile.audioId);
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

    getPlaylist();
    playAudio();
    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
      if (state == PlayerState.completed) {
        WakelockPlus.disable();
      }
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });

      if (widget.audioFile.duration == 'unknow') {
        String audioDuration = formatDurationInHhMmSs(duration);
        API().setAudioDuration(widget.audioFile.audioId, "'$audioDuration");
      }
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
      if (isLastTrack == false &&
          currentTrack != playList.length - 1 &&
          newPosition.inSeconds > playList[currentTrack + 1]) {
        currentTrack = currentTrack + 1;
        isFirstTrack = false;
        if (currentTrack == playList.length - 1) {
          isLastTrack = true;
        }
      }
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
            isTopAdLoaded
                ? Container(
                    color: Theme.of(context).colorScheme.background,
                    width: topBannerAd!.size.width.toDouble(),
                    height: topBannerAd!.size.height.toDouble(),
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: AdWidget(ad: topBannerAd!),
                  )
                : Container(
                    width: 300,
                    height: 250,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      image: widget.audioFile.coverPhoto == ''
                          ? const DecorationImage(
                              image: AssetImage('./lib/image/playing.gif'),
                              fit: BoxFit.contain,
                            )
                          : DecorationImage(
                              image: NetworkImage(widget.audioFile.coverPhoto!),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
            Container(
              width: 300,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.audioFile.audioTitleEN.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: RichText(
                      text: TextSpan(
                        text: widget.audioFile.audioTitleMM,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        children: [
                          TextSpan(text: " (${widget.audioFile.artist})"),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 300,
              height: 20,
              child: Slider(
                min: 0,
                max: duration.inSeconds.toDouble() + 0.5,
                value: position.inSeconds.toDouble(),
                activeColor: Theme.of(context).colorScheme.onBackground,
                inactiveColor: Theme.of(context).colorScheme.primaryContainer,
                thumbColor: isReadyToBack
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onBackground,
                onChanged: (value) async {
                  if (existPlaylist) {
                    for (int i = 0; i < playList.length; i++) {
                      if (value >= playList[i]) {
                        currentTrack = i;
                      }
                    }
                  }
                  final position = Duration(seconds: value.toInt());
                  await player.seek(position);
                  await player.resume();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatDurationInHhMmSs(position),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                        const Text(" | "),
                        Text(
                          formatDurationInHhMmSs(duration),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 40),
                        existPlaylist
                            ? IconButton(
                                onPressed: () {
                                  if (isFirstTrack) {
                                    isLastTrack = false;
                                  } else {
                                    currentTrack = currentTrack - 1;
                                    position = Duration(
                                        seconds: playList[currentTrack]);
                                    player.seek(position);
                                    isLastTrack = false;
                                    if (currentTrack == 0) {
                                      isFirstTrack = true;
                                    }
                                  }
                                },
                                icon: Icon(
                                  Icons.skip_previous,
                                  shadows: [
                                    BoxShadow(
                                      color:
                                          Theme.of(context).colorScheme.shadow,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      //offset: const Offset(1, 1),
                                    )
                                  ],
                                ),
                                iconSize: 25,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              )
                            : Container(),
                        IconButton(
                          onPressed: () {
                            position =
                                Duration(seconds: (position.inSeconds - 10));
                            if (position.inSeconds > 0) {
                              player.seek(position);
                            }
                          },
                          icon: Icon(
                            Icons.replay_10,
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
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        IconButton(
                          onPressed: () {
                            if (isPlaying) {
                              player.pause();
                            } else {
                              playAudio();
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
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        IconButton(
                          onPressed: () {
                            if (position.inSeconds + 10 < duration.inSeconds) {
                              position =
                                  Duration(seconds: (position.inSeconds + 10));
                              player.seek(position);
                            }
                          },
                          icon: Icon(
                            Icons.forward_10,
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
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        existPlaylist
                            ? IconButton(
                                onPressed: () {
                                  if (isLastTrack) {
                                  } else {
                                    currentTrack = currentTrack + 1;
                                    position = Duration(
                                        seconds: playList[currentTrack]);
                                    player.seek(position);
                                    isFirstTrack = false;
                                    if (currentTrack == playList.length - 1) {
                                      isLastTrack = true;
                                    }
                                  }
                                },
                                icon: Icon(
                                  Icons.skip_next,
                                  shadows: [
                                    BoxShadow(
                                      color:
                                          Theme.of(context).colorScheme.shadow,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      //offset: const Offset(1, 1),
                                    )
                                  ],
                                ),
                                iconSize: 25,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              )
                            : Container(),
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () {
                              if (player.releaseMode == ReleaseMode.release) {
                                player.setReleaseMode(ReleaseMode.loop);
                                setState(() {
                                  isRepeat = true;
                                });
                              } else {
                                player.setReleaseMode(ReleaseMode.release);
                                setState(() {
                                  isRepeat = false;
                                });
                              }
                            },
                            icon: Icon(
                              EneftyIcons.repeate_music_outline,
                              size: 24,
                              color: isRepeat ? Colors.amber : null,
                              shadows: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            iconSize: 25,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Linkify(
                    onOpen: (link) async {
                      if (!await launchUrl(Uri.parse(link.url),
                          mode: LaunchMode.externalApplication)) {
                        throw Exception('Could not launch ${link.url}');
                      }
                    },
                    text: widget.audioFile.credit,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
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
