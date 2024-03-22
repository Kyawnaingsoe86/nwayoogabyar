import 'dart:async';

import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/controller/dateformatter.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/dailyuser.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DailyRecord extends StatefulWidget {
  const DailyRecord({super.key});

  @override
  State<DailyRecord> createState() => _DailyRecordState();
}

class _DailyRecordState extends State<DailyRecord> {
  int todayActiveUser = 0;
  bool isLoading = true;
  List<DailyUser> dailyUsers = [];
  Timer? timer;

  getChartData() async {
    dailyUsers = [];
    dailyUsers = await API().getDailyUser();
  }

  Future<void> getTodayActiveUser() async {
    try {
      setState(() {
        isLoading = true;
      });
      todayActiveUser = await API().todayActiveUser();
      await getChartData();
      setState(() {
        todayActiveUser;
        dailyUsers;
        isLoading = false;
      });
    } on Exception catch (e) {
      timer = Timer(const Duration(seconds: 15), () {
        getTodayActiveUser();
      });
    }
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
        onAdLoaded: (ad) {
          setState(() {
            isTopBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
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
    loadAd();
    getTodayActiveUser();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    topBannerAd?.dispose();
    bottomBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SizedBox(
            width: double.infinity,
            height: 400,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text(
                  'Today active users',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '$todayActiveUser',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                height: 40,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(
                    width: 1,
                    style: BorderStyle.solid,
                    color: Theme.of(context).colorScheme.shadow,
                  ),
                ),
                child: Text(
                  'Top 10 Users',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 5,
                  right: 5,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                  border: Border.all(
                    width: 1,
                    style: BorderStyle.solid,
                    color: Theme.of(context).colorScheme.shadow,
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Container(
                      width: double.infinity,
                      height: 30,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Theme.of(context).colorScheme.shadow,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 30,
                            alignment: Alignment.centerRight,
                            child: Text('${index + 1} :'),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 10),
                              child:
                                  Text(UserCredential.topUsers[index].userName),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            alignment: Alignment.centerRight,
                            child: Text(
                                '${UserCredential.topUsers[index].totalPoints}'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              isTopBannerAdLoaded
                  ? Container(
                      color: Theme.of(context).colorScheme.background,
                      width: topBannerAd!.size.width.toDouble(),
                      height: topBannerAd!.size.height.toDouble(),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: AdWidget(ad: topBannerAd!),
                    )
                  : const SizedBox(
                      height: 20,
                    ),
              Container(
                width: double.infinity,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: Text(
                  'Last 7-days Active Users Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              isLoading
                  ? Container()
                  : Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      width: double.infinity,
                      height: 200,
                      child: DChartBarCustom(
                        showDomainLabel: true,
                        showMeasureLabel: false,
                        radiusBar: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                        listData: dailyUsers
                            .map((e) => DChartBarDataCustom(
                                  value: e.activeUser.toDouble(),
                                  label: DateFormatter.getDayNumber(
                                      double.parse(e.recordedDate)),
                                  showValue: true,
                                  valueStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                ))
                            .toList(),
                      ),
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
              Container(
                width: double.infinity,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: Text(
                  'Last 7-days Contribution (Est.)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              isLoading
                  ? Container()
                  : Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      width: double.infinity,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          var status = 'M';
                          if (index != 0) {
                            double diffIncome = (dailyUsers[index].estIncome -
                                dailyUsers[index - 1].estIncome);
                            if (diffIncome < 0) {
                              status = "D";
                            } else if (diffIncome > 0) {
                              status = 'I';
                            }
                          }
                          return Container(
                            width: double.infinity,
                            height: 30,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.shadow,
                            ))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Text(dailyUsers[index].dateString),
                                  ),
                                ),
                                index == 6
                                    ? Container(
                                        height: 30,
                                        margin: const EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                        ),
                                        alignment: Alignment.centerRight,
                                        child: const Text('not fix >>'),
                                      )
                                    : Container(),
                                Container(
                                  width: 10,
                                  height: 30,
                                  alignment: Alignment.centerRight,
                                  child: status == 'M'
                                      ? const Text(
                                          '\u25AA',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.blue,
                                          ),
                                        )
                                      : status == 'I'
                                          ? const Text(
                                              '\u2B06',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.green,
                                              ),
                                            )
                                          : const Text(
                                              '\u2B07',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.red,
                                              ),
                                            ),
                                ),
                                Container(
                                  width: 60,
                                  alignment: Alignment.centerRight,
                                  child: Text('${dailyUsers[index].estIncome}'),
                                ),
                                Container(
                                  width: 40,
                                  alignment: Alignment.centerRight,
                                  child: const Text('SGD'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Contact us:',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
              )
            ],
          );
  }
}
