import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/theme_provider.dart';
import 'package:nwayoogabyar/view/startpage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  UserCredential.version = packageInfo.version;
  UserCredential.buildNumber = packageInfo.buildNumber;
  UserCredential.currentAppVersion =
      "${UserCredential.version}+${UserCredential.buildNumber}";

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nway Oo Gabyar',
      debugShowCheckedModeBanner: false,
      home: const StartPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
