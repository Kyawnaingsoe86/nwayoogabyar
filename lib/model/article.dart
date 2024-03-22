class Article {
  String id;
  String timestamp;
  String titleMM;
  String contentMM;
  String titleEN;
  String contentEN;
  String category;
  String author;
  String source;
  String coverPhoto;

  Article({
    required this.id,
    required this.timestamp,
    required this.titleMM,
    required this.contentMM,
    required this.titleEN,
    required this.contentEN,
    required this.category,
    required this.author,
    required this.source,
    required this.coverPhoto,
  });

  factory Article.fromJson(dynamic json) => Article(
        id: "$json['id']",
        timestamp: "$json['timestamp']",
        titleMM: "$json['titleMM']",
        contentMM: "$json['contentMM']",
        titleEN: "$json['titleEN']",
        contentEN: "$json['contentEN']",
        category: "$json['category']",
        author: "$json['author']",
        source: "$json['source']",
        coverPhoto: "$json['coverPhoto']",
      );

  Map toJson() => {
        "id": id,
        "timestamp": timestamp,
        "titleMM": titleMM,
        "contentMM": contentMM,
        "titleEN": titleEN,
        "contentEN": contentEN,
        "category": category,
        "author": author,
        "source": source,
        "coverPhoto": coverPhoto,
      };
}
