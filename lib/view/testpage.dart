import 'package:flutter/material.dart';
import 'package:nwayoogabyar/controller/appscriptapi.dart';
import 'package:nwayoogabyar/model/comment.dart';
import 'package:nwayoogabyar/model/post.dart';
import 'package:nwayoogabyar/model/profile.dart';

class MyTestPage extends StatefulWidget {
  const MyTestPage({super.key});

  @override
  State<MyTestPage> createState() => _MyTestPageState();
}

class _MyTestPageState extends State<MyTestPage> {
  List<Profile> profiles = [];
  List<Post> posts = [];
  List<Comment> comments = [];
  testfunction() async {
    comments = await AppsScriptAPI().getComments();
    print('Comments loaded');
    setState(() {
      profiles;
      posts;
      comments;
    });
  }

  @override
  void initState() {
    testfunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return Text(comments[index].commentId);
        },
      ),
    );
  }
}
