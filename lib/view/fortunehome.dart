import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/view/fortunequestion.dart';
import 'package:nwayoogabyar/view/profile.dart';

class FortuneHomePage extends StatefulWidget {
  const FortuneHomePage({super.key});

  @override
  State<FortuneHomePage> createState() => _FortuneHomePageState();
}

class _FortuneHomePageState extends State<FortuneHomePage> {
  bool adReady = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      )
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('./lib/image/jackpot/fortuneball.jpg'),
                    fit: BoxFit.fitWidth),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: const Text(
              'ငါးပါးသီလကို ခံယူပါ။\n\nပြီးတော့ ဗုဒ္ဓဂုဏော အနန္တော၊ ဓမ္မဂုဏော အနန္တော၊ သံဃဂုဏော အနန္တော၊ မာတာပိတုဂုဏော အနန္တော၊ အာစရိယဂုဏော အနန္တော၊ ပဉ္စဂုဏံ အဟံ ဝန္ဒာမိ သဗ္ဗဒါ ဟူ၍ အနန္တငါးပါးကို ၃ ကြိမ်ပူဇော်ပါ။ \n \nဓတရဋ္ဌနတ်မင်း၊ ဝိရုဠက နတ်မင်း၊ ဝိရုပက္ခနတ်မင်း၊ ကုဝေရနတ်မင်းကြီးတို့အား ပူဇော်ကန်တော့ပါ။ \n\nကျွန်တော်/ကျွန်မတို့ကို ဟုတ်တိုင်းမှန်ရာ အထင်အရှားပြတော်မူပါဟုဆိုပြီး၊ မေးခွန်း ၄၂ ခုတွင် မိမိမေးလိုရာ မေးခွန်းကို မေးမြန်းပါ။ ပြီးပါက မိမိအာရုံရသည့် ကဒ်တစ်ခုကိုရွေးချယ်၍ မိမိမေးခွန်း၏ အဖြေကို ကြည့်ရှုပါ။',
              textAlign: TextAlign.justify,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 15),
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                if (UserCredential.flipChance > 0) {
                  UserCredential.addFlipChance(-1);
                  setState(() {
                    UserCredential.flipChance;
                  });
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const FortuneQuestionPage(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.start_outlined),
              label: const Text(
                'Get start',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Text('Chance: ${UserCredential.flipChance}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  if (adReady) {
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('No Ads'),
                        content: const Text(
                            'Ads is not ready. Please try again later.'),
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
                  }
                },
                child: const Text('Watch Ads'),
              ),
              TextButton(
                onPressed: () {
                  if (UserCredential.userProfile.remainedPoints >= 2) {
                    UserCredential.deductPoints(2);
                    UserCredential.addFlipChance(1);
                    setState(() {
                      UserCredential.flipChance;
                    });
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('No enough stars'),
                        content: const Text('Sorry, you have no enough stars.'),
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
                  }
                },
                child: const Text('Use Stars'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
