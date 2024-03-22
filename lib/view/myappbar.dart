import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/view/profile.dart';

AppBar myAppBar(BuildContext context, bool adReady) {
  return AppBar(
    automaticallyImplyLeading: true,
    scrolledUnderElevation: 1,
    elevation: 1,
    shadowColor: Theme.of(context).colorScheme.shadow,
    backgroundColor: Theme.of(context).colorScheme.background,
    foregroundColor: Theme.of(context).colorScheme.onBackground,
    title: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
      },
      child: Text(
        'နွေဦးကဗျာ',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontFamily: 'Masterpiece Spring Revolution',
          fontSize: 30,
        ),
      ),
    ),
    centerTitle: true,
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
  );
}
