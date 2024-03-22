class VideoFile {
  String videoId;
  String videoLink;
  String videTitle;
  String likedIds;
  String timestamp;

  VideoFile({
    required this.videoId,
    required this.videoLink,
    required this.videTitle,
    required this.likedIds,
    required this.timestamp,
  });

  factory VideoFile.fromJson(dynamic json) => VideoFile(
        videoId: "${json['videoId']}",
        videoLink: "${json['videoId']}",
        videTitle: "${json['videoId']}",
        likedIds: "${json['videoId']}",
        timestamp: "${json['videoId']}",
      );

  Map toJson() => {
        "videoId": videoId,
        "videoLink": videoLink,
        "videTitle": videTitle,
        "likedIds": likedIds,
        "timestamp": timestamp,
      };
}
