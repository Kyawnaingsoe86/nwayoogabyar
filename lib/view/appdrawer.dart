import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/sprf.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/color_schemes.dart';
import 'package:nwayoogabyar/theme/theme_provider.dart';
import 'package:nwayoogabyar/view/aboutus.dart';
import 'package:nwayoogabyar/view/googleform.dart';
import 'package:nwayoogabyar/view/login.dart';
import 'package:nwayoogabyar/view/profile.dart';
import 'package:nwayoogabyar/view/screenshot.dart';
import 'package:nwayoogabyar/view/supportedlist.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isDark = false;

  get getProfileImage =>
      UserCredential.userProfile.userAvatar.startsWith('http')
          ? NetworkImage(UserCredential.userProfile.userAvatar)
          : AssetImage(UserCredential.userProfile.userAvatar);

  checkThemeMode() {
    setState(() {
      Provider.of<ThemeProvider>(context).themeData == darkMode
          ? isDark = true
          : isDark = false;
    });
  }

  Widget drawerItem(IconData icon, String title,
      [Widget? targetPage, var function]) {
    return GestureDetector(
      onTap: () {
        if (targetPage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => targetPage,
            ),
          );
        }
        if (function != null) {
          function;
          Navigator.pop(context);
        }
      },
      child: Container(
        width: double.infinity,
        height: 40,
        margin: const EdgeInsets.only(bottom: 5, left: 5, right: 2),
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Icon(
                icon,
                size: 16,
              ),
            ),
            Text(
              title,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode();
    return Drawer(
      surfaceTintColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(UserCredential.userProfile.headerImg),
                fit: BoxFit.cover,
              ),
            ),
            child: Text(
              'နွေဦးကဗျာ',
              style: TextStyle(
                fontFamily: 'Masterpiece Spring Revolution',
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
                shadows: [
                  Shadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 3,
                    offset: const Offset(1, 0),
                  )
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: const EdgeInsets.only(
              bottom: 5,
              top: 5,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Version - ${UserCredential.version}+${UserCredential.buildNumber}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: getProfileImage,
                          fit: BoxFit.cover,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  ),
                  Text(
                    UserCredential.userProfile.id,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Expanded(
                child: Stack(
                  alignment: const Alignment(1, 2),
                  children: [
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            UserCredential.userProfile.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                              'Total Points: ${UserCredential.userProfile.totalPoints}'),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                              'Today Points: ${UserCredential.getTodayPoints()}'),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScreenShot(),
                            ));
                      },
                      icon: const Icon(Icons.screenshot),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                EneftyIcons.sun_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Switch(
                    trackOutlineColor: MaterialStateColor.resolveWith(
                        (states) => Colors.black26),
                    inactiveThumbColor: Theme.of(context).colorScheme.primary,
                    value: isDark,
                    onChanged: (value) {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    }),
              ),
              Icon(
                EneftyIcons.moon_bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          drawerItem(
            EneftyIcons.award_outline,
            'Supported List',
            const SupportedList(),
          ),
          drawerItem(
            EneftyIcons.information_outline,
            'About Us',
            const InfoPage(title: 'About Us', infoKey: 'about_us'),
          ),
          drawerItem(
            EneftyIcons.security_safe_outline,
            'Privacy Policy',
            const InfoPage(title: 'Privacy Policy', infoKey: 'privacy_policy'),
          ),
          drawerItem(
            EneftyIcons.task_square_outline,
            'Terms and Conditions',
            const InfoPage(
                title: 'Terms and Conditions', infoKey: 'terms_conditions'),
          ),
          drawerItem(
            EneftyIcons.eraser_outline,
            'Reset consent state',
            null,
            ConsentInformation.instance.reset(),
          ),
          drawerItem(
            EneftyIcons.send_2_outline,
            'Send File',
            const MyGoogleForm(),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: Text(
                  "Contact Us:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  launchUrlString(
                    'https://www.facebook.com/OurSoulFutureMM',
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Color(0xFF1877F2),
                ),
              ),
              IconButton(
                onPressed: () {
                  launchUrlString(
                    'https://m.me/OurSoulFutureMM',
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.facebookMessenger,
                  color: Color(0xFF00B2FF),
                ),
              ),
              IconButton(
                onPressed: () {
                  launchUrlString(
                    'https://t.me/+ybSVDMxAU1JhYjdl',
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.telegram,
                  color: Color(0xFF229ED9),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            child: TextButton.icon(
                onPressed: () {
                  Sprf().deleteSprf();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                },
                icon: const Icon(EneftyIcons.logout_outline),
                label: const Text('Logout')),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
