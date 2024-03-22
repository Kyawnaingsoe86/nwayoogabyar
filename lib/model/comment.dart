class Comment {
  String commentId;
  String timestamp;
  String comment;
  String postId;
  String userId;

  Comment({
    required this.commentId,
    required this.timestamp,
    required this.comment,
    required this.postId,
    required this.userId,
  });

  factory Comment.fromJson(dynamic json) => Comment(
        commentId: "${json['commentId']}",
        timestamp: "${json['timestamp']}",
        comment: "${json['comment']}",
        postId: "${json['postId']}",
        userId: "${json['userId']}",
      );
}
