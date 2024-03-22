import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/controller/sprf.dart';
import 'package:nwayoogabyar/model/article.dart';
import 'package:nwayoogabyar/model/audiofile.dart';
import 'package:nwayoogabyar/model/blogcomment.dart';
import 'package:nwayoogabyar/model/blogpost.dart';
import 'package:nwayoogabyar/model/certificate.dart';
import 'package:nwayoogabyar/model/dailyrecord.dart';
import 'package:nwayoogabyar/model/post.dart';
import 'package:nwayoogabyar/model/profile.dart';
import 'package:nwayoogabyar/model/storyphoto.dart';
import 'package:nwayoogabyar/model/videofile.dart';

class UserCredential {
  static String version = '';
  static String buildNumber = '';
  static String currentAppVersion = '';
  static String themeMode = 'lightMode';
  static int flipChance = 0;

  static late Profile userProfile;
  static bool isNew = true;

  static List<String> categories = ['All'];
  static List<Post> posts = [];
  static List<dynamic> postLikeList = [];

  static List<String> avatars = [
    './lib/image/avatars/Avatar_01.png',
    './lib/image/avatars/Avatar_02.png',
    './lib/image/avatars/Avatar_03.png',
    './lib/image/avatars/Avatar_04.png',
    './lib/image/avatars/Avatar_05.png',
    './lib/image/avatars/Avatar_06.png',
    './lib/image/avatars/Avatar_07.png',
    './lib/image/avatars/Avatar_08.png',
    './lib/image/avatars/Avatar_09.png',
    './lib/image/avatars/Avatar_10.png',
    './lib/image/avatars/Avatar_11.png',
    './lib/image/avatars/Avatar_12.png',
    './lib/image/avatars/Avatar_13.png',
    './lib/image/avatars/Avatar_14.png',
    './lib/image/avatars/Avatar_15.png',
    './lib/image/avatars/Avatar_16.png',
    './lib/image/avatars/Avatar_17.png',
    './lib/image/avatars/Avatar_18.png',
    './lib/image/avatars/Avatar_19.png',
    './lib/image/avatars/Avatar_20.png',
    './lib/image/avatars/Avatar_21.png',
    './lib/image/avatars/Avatar_22.png',
    'https://i.postimg.cc/wv4sqvNL/Papirus-Team-Papirus-Apps-Upload-pictures.png',
  ];

  static List<String> headerImages = [
    './lib/image/headers/header_01.png',
    './lib/image/headers/header_02.png',
    './lib/image/headers/header_03.png',
    './lib/image/headers/header_04.png',
    './lib/image/headers/header_05.png',
    './lib/image/headers/header_06.png',
    './lib/image/headers/header_07.png',
    './lib/image/headers/header_08.png',
    './lib/image/headers/header_09.png',
    './lib/image/headers/header_10.png',
    './lib/image/headers/header_11.png',
    './lib/image/headers/header_12.png',
    './lib/image/headers/header_13.png',
    './lib/image/headers/header_14.png',
    './lib/image/headers/header_15.png',
    './lib/image/headers/header_16.png',
  ];

  static List<Profile> profiles = [];
  static List<String> audioCategories = [];
  static List<AudioFile> audios = [];
  static List<Profile> topUsers = [];
  static List<VideoFile> videos = [];
  static List<Article> articles = [];
  static List<String> articleCategories = [];

  static Set<String> clickedId = {};
  static double maxY = 0;
  static String dailyActivity = '';
  static List<UserDailyRecord> userDailyRecords = [];
  static List<Certificate> userCertificates = [];

  static List<BlogPost> blogPosts = [];
  static List<BlogComment> blogComments = [];
  static List<BlogComment> replyBlogComments = [];
  static List<String> commentedBlogIds = [];
  static List<StoryPhoto> storyPhotos = [];
  static List<String> ytchannelLinks = [];

  static setUserCredential() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day + 0);

    if (userProfile.dailyActivity != 'null') {
      final List<dynamic> dataList = jsonDecode(userProfile.dailyActivity);
      userDailyRecords = [];
      for (int i = 0; i < dataList.length; i++) {
        userDailyRecords.add(UserDailyRecord(
          clickDate: '${dataList[i]['Date']}',
          points: dataList[i]['Points'],
        ));
      }

      DateTime lastClickDate = DateTime.parse(userDailyRecords.last.clickDate);
      int notClickDays = today.difference(lastClickDate).inDays;

      if (notClickDays > 0) {
        for (int i = notClickDays; i > 0; i--) {
          userDailyRecords.removeAt(0);
          userDailyRecords.add(UserDailyRecord(
              clickDate: DateFormat('yyyyMMdd')
                  .format(today.subtract(Duration(days: i - 1))),
              points: 0));
        }
      }
    } else {
      userDailyRecords = [];
      for (int i = 6; i >= 0; i--) {
        userDailyRecords.add(UserDailyRecord(
          clickDate:
              DateFormat('yyyyMMdd').format(today.subtract(Duration(days: i))),
          points: 0,
        ));
      }
    }
    dailyActivityToString();

    if (userProfile.certificate != "[]") {
      List<dynamic> result = jsonDecode(userProfile.certificate);
      for (int i = 0; i < result.length; i++) {
        userCertificates.add(
          Certificate(
            level: result[i]['level'],
            certificateUrl: result[i]['url'],
          ),
        );
      }
    } else {
      userCertificates = [];
    }
    Sprf().setSprf(userProfile.id);
    await API().editUserDailyActivity(userProfile.id);
  }

  static changeName(String newName) {
    userProfile.userName = newName;
  }

  static changePassword(String newPassword) {
    userProfile.password = newPassword;
  }

  static changeBio(String bio) {
    userProfile.userBio = bio;
    API().editUserBio(userProfile.id, bio);
  }

  static changeHeaderImage(String headerImage) {
    userProfile.headerImg = headerImage;
    API().editProfileHeader(userProfile.id, headerImage);
  }

  static addFlipChance(int chance) {
    flipChance = flipChance + chance;
    Sprf().editFlipChance(flipChance);
  }

  static Profile? getBlogProfile(String id) {
    for (int i = 0; i < profiles.length; i++) {
      if (profiles[i].id == id) {
        return profiles[i];
      }
    }
    return null;
  }

  static String getUserName(String id) {
    for (int i = 0; i < profiles.length; i++) {
      if (profiles[i].id == id) {
        return profiles[i].userName;
      }
    }
    return '';
  }

  static String getUserAvatar(String id) {
    for (int i = 0; i < profiles.length; i++) {
      if (profiles[i].id == id) {
        return profiles[i].userAvatar;
      }
    }
    return '';
  }

  static editBlogProfileAvatar(String id, String avatar) {
    for (int i = 0; i < profiles.length; i++) {
      if (profiles[i].id == id) {
        profiles[i].userAvatar = avatar;
        break;
      }
    }
  }

  static List<BlogPost> getUserBlogPost(String id) {
    List<BlogPost> posts = [];
    for (int i = 0; i < blogPosts.length; i++) {
      if (blogPosts[i].userId == id) {
        posts.add(blogPosts[i]);
      }
    }
    return posts;
  }

  static increaseDailyPoints() {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day + 0);
    DateTime lastClickDate = DateTime.parse(userDailyRecords.last.clickDate);

    int notClickDays = today.difference(lastClickDate).inDays;

    if (notClickDays > 0) {
      for (int i = notClickDays; i >= 0; i--) {
        userDailyRecords.removeAt(0);
        userDailyRecords.add(UserDailyRecord(
            clickDate: DateFormat('yyyyMMdd')
                .format(today.subtract(Duration(days: i))),
            points: 0));
      }
    }

    userDailyRecords.last.points = userDailyRecords.last.points + 1;
    dailyActivityToString();
  }

  static int getTodayPoints() {
    int todayPoints = 0;
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day + 0);
    DateTime lastClickDate = DateTime.parse(userDailyRecords.last.clickDate);
    int notClickDays = today.difference(lastClickDate).inDays;
    if (notClickDays == 0) {
      todayPoints = userDailyRecords.last.points;
    }
    return todayPoints;
  }

  static dailyActivityToString() {
    dailyActivity = '';
    for (int i = 0; i < userDailyRecords.length; i++) {
      dailyActivity =
          '$dailyActivity{"Date": ${userDailyRecords[i].clickDate}, "Points": ${userDailyRecords[i].points}},';
    }
    dailyActivity = '[${dailyActivity.substring(0, dailyActivity.length - 1)}]';
  }

  static increasePoint() {
    userProfile.totalPoints++;
    userProfile.remainedPoints++;
    increaseDailyPoints();
    API().editPoints(userProfile.id);
  }

  static deductPoints(int points) {
    if (userProfile.remainedPoints < points) return -1;
    userProfile.remainedPoints = userProfile.remainedPoints - points;
    API().editPoints(userProfile.id);
    return 1;
  }

  static bool isPostLiked(String postId) {
    for (int i = 0; i < posts.length; i++) {
      if (posts[i].postId == postId) {
        return posts[i].likedUserId.contains(userProfile.id);
      }
    }
    return false;
  }

  static int getLikeCount(String postId) {
    for (int i = 0; i < posts.length; i++) {
      if (posts[i].postId == postId) {
        return posts[i].likedUserId.length ~/ 8;
      }
    }
    return 0;
  }

  static editPostLikedIds(String postId, bool isLiked) {
    for (int i = 0; i < posts.length; i++) {
      if (posts[i].postId == postId) {
        if (isLiked && !posts[i].likedUserId.contains(userProfile.id)) {
          posts[i].likedUserId = posts[i].likedUserId + userProfile.id;
        } else if (!isLiked) {
          posts[i].likedUserId =
              posts[i].likedUserId.replaceAll(userProfile.id, '');
        }
        API().editPostLikedIds(postId, isLiked);
        return;
      }
    }
  }

  static bool isPostSupported(String postId) {
    return userProfile.supportedPostId.contains(postId);
  }

  static addPostSupport(String postId) {
    if (userProfile.supportedPostId == 'null') {
      userProfile.supportedPostId = '';
    }
    userProfile.supportedPostId = '${userProfile.supportedPostId}$postId ';
    API().editUserSupport(userProfile.id, userProfile.supportedPostId);
  }

  static List<Post> getSupportedPost() {
    List<Post> supportedPosts = [];
    if (userProfile.supportedPostId == '' ||
        userProfile.supportedPostId == 'null') {
      return supportedPosts;
    } else {
      List<String> supportedIds =
          splitByLenght(userProfile.supportedPostId.replaceAll(' ', ''), 9);
      for (int i = 0; i < posts.length; i++) {
        for (int j = 0; j < supportedIds.length; j++) {
          if (posts[i].postId == supportedIds[j]) {
            supportedPosts.add(posts[i]);
          }
        }
      }
    }
    return supportedPosts;
  }

  static List<String> splitByLenght(String string, int length) {
    int start = 0;
    List<String> stringList = [];
    while (string.length > start) {
      if ((start + length) < string.length) {
        stringList.add(string.substring(start, start + length));
      } else {
        stringList.add(string.substring(start));
      }
      start = start + length;
    }

    return stringList;
  }

  static changeUserAvatar(String avatarLink) async {
    userProfile.userAvatar = avatarLink;
    await API().editUserAvatar(userProfile.id, avatarLink);
    editBlogProfileAvatar(userProfile.id, avatarLink);
  }

  static increaseJackpotTicket(int ticket) {
    userProfile.jackpotTicket = userProfile.jackpotTicket + ticket;
    API().editJackpotTicket();
  }

  static decreaseJackpotTicket(int ticket) {
    userProfile.jackpotTicket = userProfile.jackpotTicket - ticket;
    API().editJackpotTicket();
  }

  static setClickedId(String id) {
    clickedId.add(id);
  }

  static isClicked(String id) {
    return clickedId.contains(id);
  }

  static changeBlogLike(String blogId, bool isLike) {
    String likedId = '';
    int index = 0;
    for (int i = 0; i < blogPosts.length; i++) {
      if (blogPosts[i].id == blogId) {
        index = i;
        likedId = blogPosts[i].likedId;
        break;
      }
    }
    if (isLike) {
      likedId.contains(userProfile.id)
          ? likedId
          : likedId = likedId + userProfile.id;
    } else {
      likedId = likedId.replaceAll(userProfile.id, '');
    }

    blogPosts[index].likedId = likedId;
    print(blogPosts[index].likedId);
    API().editBlogLike(blogPosts[index].id, isLike);
  }

  static bool isBlogLike(String blogId, String id) {
    String likedId = '';
    for (int i = 0; i < blogPosts.length; i++) {
      if (blogPosts[i].id == blogId) {
        likedId = blogPosts[i].likedId;
        break;
      }
    }
    if (likedId == '') {
      return false;
    } else {
      if (likedId.contains(id)) {
        return true;
      }
    }
    return false;
  }

  static int getBlogLikeCount(String blogId) {
    String likedId = '';

    for (int i = 0; i < blogPosts.length; i++) {
      if (blogPosts[i].id == blogId) {
        likedId = blogPosts[i].likedId;
        break;
      }
    }
    if (likedId == '') {
      return 0;
    } else {
      return likedId.length ~/ 8;
    }
  }

  static int getBlogCommentCount(String blogId) {
    int count = 0;
    for (int i = 0; i < commentedBlogIds.length; i++) {
      if (commentedBlogIds[i] == blogId) {
        count++;
      }
    }
    return count;
  }

  static List<BlogComment> getReplyBlogComment(String blogCommentId) {
    List<BlogComment> temp = [];
    for (int i = 0; i < replyBlogComments.length; i++) {
      if (replyBlogComments[i].replyToId == blogCommentId) {
        temp.add(replyBlogComments[i]);
      }
    }
    return temp;
  }
}
