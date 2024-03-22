import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:ip_country_lookup/models/ip_country_data_model.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/dailyrecord.dart';
import 'package:nwayoogabyar/view/changeprofilepic.dart';
import 'package:ip_country_lookup/ip_country_lookup.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showPassword = false;

  get getAvatar => UserCredential.userProfile.userAvatar.startsWith('http')
      ? NetworkImage(UserCredential.userProfile.userAvatar)
      : AssetImage(UserCredential.userProfile.userAvatar);

  profileRow(String title, String content, [bool? editable, bool? password]) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  password != null
                      ? showPassword
                          ? content
                          : '*******'
                      : content,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              password != null
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Icon(
                          showPassword
                              ? EneftyIcons.eye_outline
                              : EneftyIcons.eye_slash_outline,
                        ),
                      ),
                    )
                  : Container(),
              editable != null
                  ? GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              password != null ? editPassword() : editName(),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: const Icon(EneftyIcons.edit_outline),
                      ),
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }

  rebuildProfilePage() {
    setState(() {});
  }

  editName() {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController rename = TextEditingController();
    return AlertDialog(
      shape: DesignProvider.getDialogBoxShape(10),
      title: const Text('Edit'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: rename..text = UserCredential.userProfile.userName,
          validator: (value) {
            if (value == '') {
              return 'Name cannot be empty!';
            } else {
              return null;
            }
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              UserCredential.changeName(rename.text);
              API().changeName(UserCredential.userProfile.id, rename.text);
              rebuildProfilePage();
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  editPassword() {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController password = TextEditingController();
    return AlertDialog(
      shape: DesignProvider.getDialogBoxShape(10),
      title: const Text('Edit'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: password..text = UserCredential.userProfile.password,
          validator: (value) {
            if (value == null || value == '') {
              return 'Please enter password';
            } else if (value.length < 5) {
              return 'Password must has at least 5 characters.';
            } else if (value.contains(' ')) {
              return 'Space is not allowed.';
            } else if (!value.contains(RegExp(r'[0-9]'))) {
              return 'Password must has digits';
            } else if (!value.contains(RegExp(r'[a-zA-Z]'))) {
              return 'Password must has character';
            } else {
              return null;
            }
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              UserCredential.changePassword(password.text);
              API()
                  .changePassword(UserCredential.userProfile.id, password.text);
              rebuildProfilePage();
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  profileCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 2,
            )
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 110,
                height: 110,
                margin: const EdgeInsets.only(
                  left: 5,
                  right: 5,
                  top: 5,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 1,
                    ),
                  ],
                  image: DecorationImage(
                    image: getAvatar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ChangeProfilePicture())).then((value) {
                    setState(() {});
                  });
                },
                child: Container(
                  width: 110,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Change Avatar',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              )
            ],
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              profileRow('User id:', UserCredential.userProfile.id),
              profileRow(
                  'User Name:', UserCredential.userProfile.userName, true),
              profileRow(
                  'Password', UserCredential.userProfile.password, true, true),
              Row(
                children: [
                  Expanded(
                    child: profileRow('Total Stars:',
                        '${UserCredential.userProfile.totalPoints}'),
                  ),
                  Expanded(
                    child: profileRow('Remaining Stars:',
                        '${UserCredential.userProfile.remainedPoints}'),
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  String country = '';
  int divider = 5000;
  Future<void> loadData() async {
    IpCountryData countryData = await IpCountryLookup().getIpLocationData();
    int multiplier = UserCredential.userProfile.totalPoints ~/ 5000;
    divider = divider * (multiplier + 1);
    setState(() {
      country = '(${countryData.country_name.toString()})';
    });
  }

  Widget userDailyPoint(int index) {
    DateTime clickDate =
        DateTime.parse(UserCredential.userDailyRecords[index].clickDate);
    String clickDay = DateFormat('E').format(clickDate);
    String pointStatus = 'M';
    if (index != 0) {
      int diffPoints = UserCredential.userDailyRecords[index].points -
          UserCredential.userDailyRecords[index - 1].points;
      if (diffPoints < 0) {
        pointStatus = 'D';
      } else if (diffPoints > 0) {
        pointStatus = 'I';
      }
    }
    return Container(
      width: index == 6 ? 162 : 80,
      height: 80,
      margin: const EdgeInsets.symmetric(
        horizontal: 1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 1,
                  )
                ]),
            child: Text.rich(
              TextSpan(
                text: '${UserCredential.userDailyRecords[index].points}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                children: [
                  pointStatus == 'I'
                      ? const TextSpan(
                          text: '\u2B06',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : pointStatus == 'D'
                          ? const TextSpan(
                              text: '\u2B07',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : const TextSpan(
                              text: '\u25AA',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(3),
                bottomRight: Radius.circular(3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 1,
                )
              ],
            ),
            child: Text(
              index == 6 ? 'TODAY' : clickDay.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget blankCard() {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.symmetric(
        horizontal: 1,
      ),
    );
  }

  BannerAd? topBannerAd;
  bool isTopBannerAdLoaded = false;

  BannerAd? bottomBannerAd;
  bool isBottomBannerAdLoaded = false;

  void loadAd() {
    topBannerAd = BannerAd(
      adUnitId: AdHelper.topBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isTopBannerAdLoaded = true;
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

    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bottomBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    loadData();
    loadAd();
    super.initState();
  }

  @override
  void dispose() {
    topBannerAd?.dispose();
    bottomBannerAd?.dispose();
    super.dispose();
  }

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
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(EneftyIcons.close_outline)),
          ]),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 20,
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.primary,
              child: Text(
                'Version: ${UserCredential.version} +${UserCredential.buildNumber} $country',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    profileCard(),
                    isTopBannerAdLoaded
                        ? Container(
                            width: topBannerAd!.size.width.toDouble(),
                            height: topBannerAd!.size.height.toDouble(),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: AdWidget(ad: topBannerAd!),
                          )
                        : const SizedBox(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      margin: const EdgeInsets.all(5),
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Text.rich(TextSpan(
                          text: (UserCredential.userProfile.totalPoints /
                                  divider *
                                  100)
                              .toStringAsFixed(2),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                          ),
                          children: const [
                            TextSpan(
                                text: '%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                          ])),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        'You will get letter of appreciation for contribution of our donation to refugees when you get $divider stars. Please make a request when you get $divider stars for printing certificate via Messenger.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    UserCredential.userCertificates.isEmpty
                        ? Container()
                        : Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: UserCredential.userCertificates.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 6 / 4,
                              ),
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: () {
                                  launchUrlString(
                                      UserCredential.userCertificates[index]
                                          .certificateUrl,
                                      mode: LaunchMode.externalApplication);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .shadow,
                                        spreadRadius: 0,
                                        blurRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: Image.network(
                                    UserCredential
                                        .userCertificates[index].certificateUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .shadow),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                    Container(
                      width: double.infinity,
                      height: 40,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Your 7-days Performance',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        userDailyPoint(0),
                        userDailyPoint(1),
                        userDailyPoint(2),
                        userDailyPoint(3),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        userDailyPoint(4),
                        userDailyPoint(5),
                        userDailyPoint(6),
                      ],
                    ),
                    isBottomBannerAdLoaded
                        ? Container(
                            color: Theme.of(context).colorScheme.background,
                            width: bottomBannerAd!.size.width.toDouble(),
                            height: bottomBannerAd!.size.height.toDouble(),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: AdWidget(ad: bottomBannerAd!),
                          )
                        : const SizedBox(
                            height: 40,
                          ),
                    const DailyRecord(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
