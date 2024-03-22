class BlogComment {
  String id;
  String timestamp;
  String comment;
  String userId;
  String blogId;
  String? replyToId;

  BlogComment({
    required this.id,
    required this.timestamp,
    required this.comment,
    required this.userId,
    required this.blogId,
    this.replyToId,
  });

  factory BlogComment.fromJson(dynamic json) => BlogComment(
        id: "${json['id']}",
        timestamp: "${json['timestamp']}",
        comment: "${json['comment']}",
        userId: "${json['userId']}",
        blogId: "${json['blogId']}",
        replyToId: "${json['replyToId']}",
      );

  Map toJson() => {
        "id": id,
        "timestamp": timestamp,
        "comment": comment,
        "userId": userId,
        "blogId": blogId,
        "replyToId": replyToId,
      };
}
