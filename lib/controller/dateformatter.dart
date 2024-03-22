import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class DateFormatter {
  static getDateFromDouble(double value) {
    return DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(
        ((value - 25569) * 86400000).toInt(),
        isUtc: true));
  }

  static getDateTimeFromDouble(double value) {
    return DateFormat('dd-MM-yyyy hh:mm:ss').format(
        DateTime.fromMillisecondsSinceEpoch(
            ((value - 25569) * 86400000).toInt(),
            isUtc: true));
  }

  static getDate(double value) {
    return DateTime.fromMillisecondsSinceEpoch(
      ((value - 25569) * 86400000).toInt(),
      isUtc: true,
    );
  }

  static getDayNumber(double value) {
    String weekday = DateFormat('E').format(DateTime.fromMillisecondsSinceEpoch(
        ((value - 25569) * 86400000).toInt(),
        isUtc: true));
    return weekday;
  }

  static getWeekdayNumber(double value) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
        ((value - 25569) * 86400000).toInt(),
        isUtc: true);
    return date.weekday;
  }

  static getPostedAge(double value) {
    print(value);
    return Jiffy.parse(getDate(value).toString()).fromNow();
  }
}
