import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nwayoogabyar/data/credential.dart';

class ScreenShot extends StatelessWidget {
  const ScreenShot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 1,
        elevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow,
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        title: Text(
          'နွေဦးကဗျာ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Masterpiece Spring Revolution',
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              './lib/image/Logo.png',
              width: 80,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Text(
              'Daily Report',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 20, right: 20),
            child: Text(
              'Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 20,
              bottom: 20,
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: getImage(),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.shadow,
                          width: 2,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        UserCredential.userProfile.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          UserCredential.userProfile.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
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
                          'Today Points: ${UserCredential.getTodayPoints()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Image.asset(
                  './lib/image/NwayOoGabyar.png',
                  width: 110,
                ),
                const Text('Printed by'),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: const Text(
              '"အရေးတော်ပုံ အောင်ရမည်။"',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Masterpiece Spring Revolution',
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          Container(
            margin: const EdgeInsets.only(
              left: 5,
              right: 5,
              bottom: 10,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                Radius.circular(5),
              ))),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider getImage() {
    String imgFile = UserCredential.userProfile.userAvatar;
    if (imgFile.startsWith('http')) {
      return NetworkImage(imgFile);
    } else {
      return AssetImage(imgFile);
    }
  }
}
