import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/controller/dateformatter.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/storyphoto.dart';

class ViewStoryPhoto extends StatefulWidget {
  final StoryPhoto storyPhoto;
  const ViewStoryPhoto({super.key, required this.storyPhoto});

  @override
  State<ViewStoryPhoto> createState() => _ViewStoryPhotoState();
}

class _ViewStoryPhotoState extends State<ViewStoryPhoto> {
  bool isLoading = false;
  Timer? _timer;
  Timer? _counter;
  int counter = 0;

  runTimer() {
    counter = 0;
    if (widget.storyPhoto.userId != UserCredential.userProfile.id &&
        !widget.storyPhoto.likedIds!.contains(UserCredential.userProfile.id)) {
      API()
          .addViewedId(widget.storyPhoto.userId, UserCredential.userProfile.id);
    }
    _counter = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (counter == 1000) timer.cancel();
      setState(() {
        counter++;
      });
    });

    _timer = Timer(const Duration(seconds: 11), () {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    runTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _counter?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                const SizedBox(height: 80),
                Expanded(
                  child: Container(
                    decoration: widget.storyPhoto.photoUrl.startsWith('http')
                        ? BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.storyPhoto.photoUrl),
                              fit: BoxFit.contain,
                            ),
                          )
                        : BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                          ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: LinearProgressIndicator(
                            value: counter / 1000,
                            backgroundColor: Colors.black26,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black12,
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: getImage(
                                        UserCredential.getUserAvatar(
                                            widget.storyPhoto.userId)),
                                  ),
                                  title: Text(
                                    UserCredential.getUserName(
                                        widget.storyPhoto.userId),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      shadows: const [
                                        BoxShadow(
                                          color: Colors.black54,
                                          spreadRadius: 3,
                                          blurRadius: 2,
                                          offset: Offset(1, 1),
                                        )
                                      ],
                                    ),
                                  ),
                                  subtitle: Text(
                                    widget.storyPhoto.timestamp.contains('-')
                                        ? 'Now'
                                        : DateFormatter.getPostedAge(
                                            double.parse(
                                                widget.storyPhoto.timestamp),
                                          ),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      shadows: const [
                                        BoxShadow(
                                          color: Colors.black54,
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                          offset: Offset(1, 1),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    EneftyIcons.close_outline,
                                    size: 40,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        Expanded(
                          child: !widget.storyPhoto.photoUrl.startsWith('http')
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      EneftyIcons.quote_down_bold,
                                      size: 40,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    Text(
                                      widget.storyPhoto.photoUrl,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shadows: [
                                          BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .shadow,
                                              blurRadius: 2,
                                              spreadRadius: 1,
                                              offset: const Offset(1, 1))
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 40)
                                  ],
                                )
                              : const SizedBox(),
                        ),
                        widget.storyPhoto.userId ==
                                UserCredential.userProfile.id
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 10,
                                          right: 5,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20))),
                                        child: RichText(
                                          text: TextSpan(
                                            text:
                                                '${widget.storyPhoto.likedIds!.length ~/ 8}',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              fontSize: 16,
                                            ),
                                            children: const [
                                              WidgetSpan(
                                                child: Icon(
                                                  EneftyIcons.eye_outline,
                                                  size: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    child: IconButton(
                                      onPressed: () async {
                                        _timer?.cancel();
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await API().deleteStoryPhoto(
                                            UserCredential.userProfile.id);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      icon: Icon(
                                        EneftyIcons.trash_bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          isLoading
              ? Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                )
              : Container(),
        ],
      ),
    );
  }

  getImage(String imgLink) {
    return imgLink.startsWith('http')
        ? NetworkImage(imgLink)
        : AssetImage(imgLink);
  }
}
