class Profile {
  String id;
  String userName;
  String password;
  int totalPoints;
  int remainedPoints;
  String leastLoginDate;
  String supportedPostId;
  String userAvatar;
  String dailyActivity;
  String userBio;
  String certificate;
  int level;
  String headerImg;
  int jackpotTicket;
  int prize;
  int wordPuzzleLevel;

  Profile({
    required this.id,
    required this.userName,
    required this.password,
    required this.totalPoints,
    required this.remainedPoints,
    required this.leastLoginDate,
    required this.supportedPostId,
    required this.userAvatar,
    required this.dailyActivity,
    required this.userBio,
    required this.certificate,
    required this.level,
    required this.headerImg,
    required this.jackpotTicket,
    required this.prize,
    required this.wordPuzzleLevel,
  });

  factory Profile.fromJson(dynamic json) => Profile(
        id: json['id'],
        userName: json['userName'],
        password: "${json['password']}",
        totalPoints: json['totalPoints'],
        remainedPoints: json['remainedPoints'],
        leastLoginDate: json['leastLoginDate'],
        supportedPostId: json['supportedPostId'],
        userAvatar: json['userAvatar'],
        dailyActivity: json['dailyActivity'],
        userBio: json['userBio'],
        certificate: json['certificate'],
        level: json['level'],
        headerImg: json['headerImg'],
        jackpotTicket: json['jackpotTicket'],
        prize: int.parse(json['prize']),
        wordPuzzleLevel: int.parse(json['wordPuzzleLevel']),
      );

  Map toJson() => {
        'ID': id,
        'userName': userName,
        'password': password,
        'totalPoints': totalPoints,
        'remainedPoints': remainedPoints,
        'leastLoginDate': leastLoginDate,
        'supportedPostId': supportedPostId,
        'userAvatar': userAvatar,
        'dailyActivity': dailyActivity,
        'userBio': userBio,
        'certificate': certificate,
        'level': level,
        'headerImg': headerImg,
        'jackpotTicket': jackpotTicket,
        'prize': prize,
        'wordPuzzleLevel': wordPuzzleLevel,
      };
}
