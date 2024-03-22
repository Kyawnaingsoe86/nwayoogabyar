class Certificate {
  int level;
  String certificateUrl;

  Certificate({required this.level, required this.certificateUrl});

  factory Certificate.fromJson(Map json) {
    return Certificate(
      level: json['level'],
      certificateUrl: json['url'],
    );
  }

  Map toJson() {
    return {
      'level': level,
      'url': certificateUrl,
    };
  }
}
