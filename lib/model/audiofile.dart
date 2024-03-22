class AudioFile {
  String audioId;
  String timeStamp;
  String audioTitleMM;
  String audioTitleEN;
  String audioCategory;
  String artist;
  String audioGenre;
  String audioUrl;
  String credit;
  String? playlist;
  String? coverPhoto;
  int playCount;
  String duration;

  AudioFile({
    required this.audioId,
    required this.timeStamp,
    required this.audioTitleMM,
    required this.audioTitleEN,
    required this.audioCategory,
    required this.artist,
    required this.audioGenre,
    required this.audioUrl,
    required this.credit,
    this.playlist,
    this.coverPhoto,
    required this.playCount,
    required this.duration,
  });

  factory AudioFile.fromJson(dynamic json) => AudioFile(
        audioId: "${json['audioId']}",
        timeStamp: "${json['timeStamp']}",
        audioTitleMM: "${json['audioTitleMM']}",
        audioTitleEN: "${json['audioTitleEN']}",
        audioCategory: "${json['audioCategory']}",
        artist: "${json['artist']}",
        audioGenre: "${json['audioGenre']}",
        audioUrl: "${json['audioUrl']}",
        credit: "${json['credit']}",
        playlist: "${json['playlist']}",
        coverPhoto: "${json['coverPhoto']}",
        playCount: json['playCount'],
        duration: "${json['duration']}",
      );

  Map toJson() => {
        "audioId": audioId,
        "timeStamp": timeStamp,
        "audioTitleMM": audioTitleMM,
        "audioTitleEN": audioTitleEN,
        "audioCategory": audioCategory,
        "artist": artist,
        "audioGenre": audioGenre,
        "audioUrl": audioUrl,
        "credit": credit,
        "playlist": playlist,
        "coverPhoto": coverPhoto,
        "playCount": playCount,
        "duration": duration,
      };
}
