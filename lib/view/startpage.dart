import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/controller/initialization_helper.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/theme/theme_provider.dart';
import 'package:nwayoogabyar/view/home.dart';
import 'package:nwayoogabyar/view/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final _initializationHelper = InitializationHelper();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String checkUser = '';
  bool reloading = false;
  bool updating = false;

  Future<void> initialize() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializationHelper.initialize();
      SharedPreferences prefs = await _prefs;
      String userId = prefs.getString('Id') ?? '';
      if (userId == '') {
        if (mounted) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Login()));
        }
      } else {
        try {
          await API().getUserById(prefs.getString('Id')!);
          if (UserCredential.isNew) {
            if (mounted) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            }
          } else {
            if (mounted) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomePage(isNewUser: false)));
            }
          }
        } on Exception catch (e) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: DesignProvider.getDialogBoxShape(10),
                title: const Text('Server Error!!'),
                content: const Text(
                    'Sorry!! Server is not responsed. Please check internet connection and try again.'),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() {
                        reloading = true;
                      });
                      Timer(const Duration(seconds: 30), () {
                        initialize();
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
    });
  }

  checkThemeMode() async {
    SharedPreferences prefs = await _prefs;
    UserCredential.themeMode = prefs.getString('themeMode') ?? 'lightMode';
    if (mounted) {
      Provider.of<ThemeProvider>(context, listen: false).setTheme();
    }
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        update();
      } else {
        initialize();
      }
    }).catchError((e) {
      initialize();
    });
  }

  void update() async {
    AppUpdateResult result = await InAppUpdate.startFlexibleUpdate();
    if (result == AppUpdateResult.userDeniedUpdate) {
      initialize();
    } else {
      InAppUpdate.startFlexibleUpdate()
          .then((value) => initialize())
          .catchError((e) async {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: DesignProvider.getDialogBoxShape(10),
            title: const Text('Error'),
            content: const Text('Error occour, app is not updated'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        initialize();
      });
    }
  }

  @override
  void initState() {
    checkThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Image.asset(
                './lib/image/Logo.png',
                width: 80,
              ),
            ),
          ),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            updating
                ? 'Updating....'
                : reloading
                    ? 'Reloading...'
                    : 'Loading.....',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.shadow,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'NWAY OO GABYAR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            'Version: ${UserCredential.version}+${UserCredential.buildNumber}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.shadow,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 30,
            alignment: Alignment.center,
            child: Text(
              'App is developed by FutureMM Development Group',
              style: TextStyle(
                color: Theme.of(context).colorScheme.shadow,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
