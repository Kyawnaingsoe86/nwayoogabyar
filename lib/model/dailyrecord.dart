class UserDailyRecord {
  String clickDate;
  int points;

  UserDailyRecord({
    required this.clickDate,
    required this.points,
  });

  factory UserDailyRecord.fromJson(Map json) {
    return UserDailyRecord(
      clickDate: json['Date'],
      points: json['Points'],
    );
  }

  Map toJson() {
    return {
      'Date': clickDate,
      'Points': points,
    };
  }
}
