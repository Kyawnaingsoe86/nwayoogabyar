import 'package:intl/intl.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sprf {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  setSprf(String userId) async {
    SharedPreferences prefs = await _prefs;
    prefs.setString('Id', userId);
    String lastDate = prefs.getString('lastDate') ?? '';
    String today = DateFormat('ddMMyyyy').format(DateTime.now());
    if (lastDate != today) {
      prefs.setString('lastDate', today);
      int flipchances = prefs.getInt('flipChance') ?? 0;
      flipchances = flipchances + 5;
      prefs.setInt('flipChance', flipchances);
      UserCredential.flipChance = flipchances;
    } else {
      UserCredential.flipChance = prefs.getInt('flipChance') ?? 5;
    }
    String latestActiveTime =
        prefs.getString('latestActiveTime') ?? DateTime.now().toString();
    DateTime currentTimer = DateTime.now();
    int differentHours =
        currentTimer.difference(DateTime.parse(latestActiveTime)).inHours;
    if (differentHours >= 1) {
      AdHelper.interstitialAdRequestTimes = 0;
    }
  }

  setLatestActiveTime() async {
    SharedPreferences prefs = await _prefs;
    prefs.setString('latestActiveTime', DateTime.now().toString());
  }

  deleteSprf() async {
    SharedPreferences prefs = await _prefs;
    prefs.clear();
  }

  setThemeMode(String themeMode) async {
    SharedPreferences prefs = await _prefs;
    prefs.setString('themeMode', themeMode);
  }

  editFlipChance(int chance) async {
    SharedPreferences prefs = await _prefs;
    prefs.setInt('flipChance', chance);
  }
}
