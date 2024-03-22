class Post {
  String postId;
  String timestamp;
  String mmTitle;
  String mmDescription;
  String enTitle;
  String enDescription;
  String coverPhotoUrl;
  String author;
  String category;
  String genre;
  String credit;
  String likedUserId;

  Post({
    required this.postId,
    required this.timestamp,
    required this.mmTitle,
    required this.mmDescription,
    required this.enTitle,
    required this.enDescription,
    required this.coverPhotoUrl,
    required this.author,
    required this.category,
    required this.genre,
    required this.credit,
    required this.likedUserId,
  });

  factory Post.fromJson(dynamic json) => Post(
        postId: "${json['postId']}",
        timestamp: "${json['timestamp']}",
        mmTitle: "${json['mmTitle']}",
        mmDescription: "${json['mmDescription']}",
        enTitle: "${json['enTitle']}",
        enDescription: "${json['enDescription']}",
        coverPhotoUrl: "${json['coverPhotoUrl']}",
        author: "${json['author']}",
        category: "${json['category']}",
        genre: "${json['genre']}",
        credit: "${json['credit']}",
        likedUserId: "${json['likedUserId']}",
      );

  Map toJson() => {
        "postId": postId,
        "timestamp": timestamp,
        "mmTitle": mmTitle,
        "mmDescription": mmDescription,
        "enTitle": enTitle,
        "enDescription": enDescription,
        "coverPhotoUrl": coverPhotoUrl,
        "author": author,
        "category": category,
        "genre": genre,
        "credit": credit,
        "likedUserId": likedUserId,
      };
}
