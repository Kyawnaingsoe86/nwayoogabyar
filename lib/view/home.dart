import 'dart:async';
import 'dart:io';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/articlepage.dart';
import 'package:nwayoogabyar/view/audiopage.dart';
import 'package:nwayoogabyar/view/blogpage.dart';
import 'package:nwayoogabyar/view/gamepage.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:nwayoogabyar/view/postpage.dart';
import 'package:nwayoogabyar/view/videopage.dart';

class HomePage extends StatefulWidget {
  final bool isNewUser;
  const HomePage({super.key, required this.isNewUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool reload = false;

  List<Widget> pages = [
    const PostPage(),
    const AudioPage(),
    const ArticalPage(),
    const VideoPage(),
    const GamePage(),
  ];
  int index = 0;

  getUserProfile() async {
    try {
      setState(() {
        isLoading = true;
      });
      await API().editLastLoginDate(UserCredential.userProfile.id);
      await API().getUserProfiles();
      setState(() {
        isLoading = false;
        reload = false;
      });
    } on Exception catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: DesignProvider.getDialogBoxShape(10),
            title: const Text('Server Error!!'),
            content: const Text(
                'Sorry!! Server is not responsed. Please try again.'),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    reload = true;
                  });
                  Timer(const Duration(seconds: 10), () {
                    getUserProfile();
                  });
                },
                child: const Text('Try again!'),
              )
            ],
          ),
        );
      }
    }
  }

  onWillPop(bool didPop) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: DesignProvider.getDialogBoxShape(10),
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Timer? _timer;
  adTimer() {
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      AdHelper.interstitialAdRequestTimes = 0;
    });
  }

  @override
  void initState() {
    adTimer();
    getUserProfile();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => onWillPop(didPop),
      child: Scaffold(
        body: reload
            ? const LoadingPage(
                title: "Nway Oo Gabyar",
                icon: EneftyIcons.cloud_change_outline,
                info: 'Re-loading...',
              )
            : isLoading
                ? const LoadingPage(
                    title: "Nway Oo Gabyar",
                    icon: EneftyIcons.cloud_change_outline,
                    info: 'Loading...',
                  )
                : pages[index],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          enableFeedback: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(EneftyIcons.book_square_outline),
              label: 'e-Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(EneftyIcons.audio_square_outline),
              label: 'Podcast',
            ),
            BottomNavigationBarItem(
              icon: Icon(EneftyIcons.document_outline),
              label: 'Article',
            ),
            BottomNavigationBarItem(
              icon: Icon(EneftyIcons.video_horizontal_outline),
              label: 'Clip',
            ),
            BottomNavigationBarItem(
              icon: Icon(EneftyIcons.game_outline),
              label: 'Game',
            )
          ],
          currentIndex: index,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
        ),
      ),
    );
  }
}
