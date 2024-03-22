class BlogPost {
  String id;
  String timestamp;
  String userId;
  String post;
  String likedId;

  BlogPost({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.post,
    required this.likedId,
  });

  factory BlogPost.fromJson(dynamic json) => BlogPost(
        id: "${json['id']}",
        timestamp: "${json['timestamp']}",
        userId: "${json['userId']}",
        post: "${json['post']}",
        likedId: "${json['likedId']}",
      );

  Map toJson() => {
        "id": id,
        "timestamp": timestamp,
        "userId": userId,
        "post": post,
        "likedId": likedId,
      };
}
