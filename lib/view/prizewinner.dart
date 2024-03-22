import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PrizeWinner extends StatefulWidget {
  final int prize;
  const PrizeWinner({
    super.key,
    required this.prize,
  });

  @override
  State<PrizeWinner> createState() => _PrizeWinnerState();
}

class _PrizeWinnerState extends State<PrizeWinner> {
  String selectedOperator = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20),
            child: Text(
              'Congratulations!!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            child: Text(
              'ဂုဏ်ယူပါတယ်',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Text(
              widget.prize == 4
                  ? 'You win 1,000Ks. Phone Bill.'
                  : 'You win 500Ks. Phone Bill.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Text(
              widget.prize == 4
                  ? 'ဖုန်းဘေလ် ၁,၀၀၀ ကျပ် ကံထူးပါတယ်။'
                  : 'ဖုန်းဘေလ် ၅၀၀ ကျပ် ကံထူးပါတယ်။',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.amber,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: const Text(
              'Please select the operator:',
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              'ငွေဖြည့်ကုဒ်ရယူလိုသည့် ဖုန်းအော်ပရေတာကိုရွေးချယ်ပါ',
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.amber,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                    image: AssetImage(selectedOperator == ""
                        ? './lib/image/jackpot/${widget.prize}.png'
                        : './lib/image/jackpot/$selectedOperator.png'))),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOperator = 'MPT';
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: const Text('MPT'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOperator = 'ATOM';
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: const Text('ATOM'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOperator = 'OOREDOO';
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: const Text('OOREDOO'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOperator = 'TICKET';
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: const Text('10Ticket'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: const Text(
              'Please take screenshot this page and send it to the Nway Oo Gabyar admin team via FB Messenger.',
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: const Text(
              '[ငွေဖြည့်ကုဒ်ရယူရန် ဤစာမျက်နှာအား screenshot ရိုက်ယူကာ FB Messenger မှတစ်ဆင့် နွေဦးကဗျာ admin team ထံသို့ ပေးပို့ဆက်သွယ်ပေးပါ။]',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: IconButton(
              onPressed: () {
                launchUrlString(
                  'https://m.me/OurSoulFutureMM',
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const FaIcon(
                FontAwesomeIcons.facebookMessenger,
                color: Color(0xFF00B2FF),
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
              '${DateFormat('yyyyMMddHHMMSS').format(DateTime.now())}${UserCredential.userProfile.id}'),
        ],
      ),
    );
  }
}
