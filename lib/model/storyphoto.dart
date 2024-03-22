class StoryPhoto {
  String userId;
  String photoUrl;
  String timestamp;
  String? likedIds;

  StoryPhoto({
    required this.userId,
    required this.photoUrl,
    required this.timestamp,
    this.likedIds,
  });

  factory StoryPhoto.fromJson(dynamic json) => StoryPhoto(
        userId: "${json['userId']}",
        photoUrl: "${json['photoUrl']}",
        timestamp: "${json['timestamp']}",
        likedIds: "${json['likedIds']}",
      );

  Map toJson() => {
        "userId": userId,
        "photoUrl": photoUrl,
        "timestamp": timestamp,
        "likedIds": likedIds,
      };
}
