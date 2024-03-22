import 'package:http/http.dart' as http;
import 'package:nwayoogabyar/model/article.dart';
import 'package:nwayoogabyar/model/audiofile.dart';
import 'package:nwayoogabyar/model/comment.dart';
import 'package:nwayoogabyar/model/post.dart';
import 'dart:convert' as convert;

import 'package:nwayoogabyar/model/profile.dart';

String scheme = 'https';
String host = 'script.google.com';

// --- Check deploy id after deploying app scripts. ----
String deplopId =
    'AKfycbw67l__Yl2I2-vNO5iv5ZAzBrT27Ur-XaNvd8fCPehW5xg6h1a6hRZJqDJEkb5d_RfB';

String path = 'macros/s/$deplopId/exec';

class AppsScriptAPI {
  Future<List<Profile>> getProfiles() async {
    List<Profile> profiles = [];
    var raw = await http.get(
      Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: {'sheet': 'users'},
      ),
    );
    var jsonProfile = convert.jsonDecode(raw.body);
    print(jsonProfile[0]);
    jsonProfile.forEach((profile) {
      profiles.add(Profile.fromJson(profile));
    });
    return profiles;
  }

  Future<List<Post>> getPosts() async {
    List<Post> posts = [];
    var raw = await http.get(
      Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: {'sheet': 'posts'},
      ),
    );
    var jsonPosts = convert.jsonDecode(raw.body);
    jsonPosts.forEach((post) {
      posts.add(Post.fromJson(post));
    });
    return posts;
  }

  Future<List<Comment>> getComments() async {
    List<Comment> comments = [];
    var raw = await http.get(
      Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: {'sheet': 'comments'},
      ),
    );
    var jsonComments = convert.jsonDecode(raw.body);
    jsonComments.forEach((comment) {
      comments.add(Comment.fromJson(comment));
    });
    return comments;
  }

  Future<List<AudioFile>> getAudios() async {
    List<AudioFile> audios = [];
    var raw = await http.get(
      Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: {'sheet': 'audios'},
      ),
    );
    var jsonAudios = convert.jsonDecode(raw.body);
    jsonAudios.forEach((audio) {
      audios.add(AudioFile.fromJson(audio));
    });
    return audios;
  }

  Future<List<Article>> getArticles() async {
    List<Article> articles = [];
    var raw = await http.get(
      Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: {'sheet': 'articles'},
      ),
    );
    var jsonArticles = convert.jsonDecode(raw.body);
    jsonArticles.forEach((article) {
      articles.add(Article.fromJson(article));
    });
    return articles;
  }
}
