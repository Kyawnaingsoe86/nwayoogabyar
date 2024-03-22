import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/article.dart';
import 'package:nwayoogabyar/model/audiofile.dart';
import 'package:nwayoogabyar/model/blogcomment.dart';
import 'package:nwayoogabyar/model/blogpost.dart';
import 'package:nwayoogabyar/model/dailyuser.dart';
import 'package:nwayoogabyar/model/post.dart';
import 'package:nwayoogabyar/model/profile.dart';
import 'package:nwayoogabyar/model/comment.dart';
import 'package:nwayoogabyar/model/puzzleimage.dart';
import 'package:nwayoogabyar/model/storyphoto.dart';
import 'package:nwayoogabyar/model/videofile.dart';

class API {
  final _credential = r'''
{
  "type": "service_account",
  "project_id": "nway-oo-gabyar",
  "private_key_id": "3b540a5d5afc38f7f28574ea9946a0b175149f75",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCs3dPIwKzfuW+a\no6Cj9qUFutcxTJbfjqpwKZKGK1JEao8g0E5I2UJv6i75j2VBkRqNekURwUARWfqO\n1ipMxfX6mDIJweXHMJhkr5rgh8cKwf43X895LZysJvBdqmhve0o/5eTS5+aLFQzr\nxHWw4VRoWhQjnd2ScXAP5Qfi0ZPT8VO0X+t7FhoOxGx9r0qo9HfpvYo8JDVXpEFy\n0wXMRzObXPihf1qO23//20dMLxnR3pUYcn6FvElLyoz+qBYOs/UNZA4tyzVYosMJ\nWl4Cguk/zCfBx1A6WJK3IU5q+yoF/jtN4s82UgYtn7cqWI1W+9kd9vD6seImmgUI\nQ27hXBDRAgMBAAECggEAC+s//hbTp8zxD7Nmt2Q7EzUp2Qmj9D/k3la6qX4ulG5y\ndiIJ6JNbHAm3rNf0J9XgHYKHy5/mK0W0dTyTOxFOxgIDa541mfFuuHzni8Hg3/JQ\nDs2QEEj5HseQ8Cxe06NarPAzDrWtm2GOrzZ8obI2CZUYaWJDoKRdd4/kZme3FR69\ngXkU8cNpt21p4faMORYsmRr+NXxXCzhwXz8TO0AGdxqSyLG6yM4EroWLDSm/qs2V\nP2e/45SGYhY5pUZh80HO/6niyOapDzj+ktupjEg3ju+RjKWxPh+z7sVs8q/OkSy7\nLmzEWaMVahMF2MrbMAmuylgHoiL9IkQGF/RUCG/DfwKBgQDqTStv8RD8NAuLIpLu\n0AhJ/ghFWMeN3k4cfJRs8hQJCXIg68kPd6CPjRzwMwzQMYsBopeCrDsKBatqUFGa\nRf51mG70qX1Bdn6J9MeILELBAwHpswW1g3nXeP54I9qErU+7OC7sl6zJsIpCTvzn\npuY3euB0nfqfta2jO0YHx4RI7wKBgQC84Ce6mPknDXh8xlB8het0gDKDGEd20Ql7\nOSkx1Q7lV+4rOu0frlBDrmR9Rs7V2KjqeZ9+CCzaQpd1vZq1uhg/U6Pw23xns3S7\nwRe4qGoOSBF05yim42Q0KlOklKp/aYwnYRgoWTtR2W65YNyY6DrRL09GyXGlOvad\nr0eQFgfCPwKBgGOPNw3yGY2Rb/ZHUrg3nc4TK+CLwP//nqFsLoW8t9a/NMfYaS8x\nXgChrdJDXwZ4huDC/i6AkPXJQvWB+6raYy4E/+DmxFq0x0BHyyGJ7TOm24E6mQpw\nO63btAXI9mm6W07qqMXQDZQGeDmE5uJogRrCE+550q1avdXGshNMLGHxAoGAbDoB\naeHX+rG0VcMJQaE3PwVqbEYQRRwY07v4R+6u32nYNntIfrvSkEWwnTxirpS8jcbt\nRjmHAfXgdf4UVYdx92+E5DHQgleJT0CgyBXw14giQJtoZuCrfVy3mvn5DJM9VR9E\nyXIAFLGDycOgBBomAdGbGpO5hBVaVRan6f9FqN8CgYBMYnPY47qE3zYEo6/1kxMA\nj3ZOS9vLFnyQkCXpmgkJObMFJ2Z359SNc4fglpUfygMTCxYOP7acUvnytRuT9beq\nk3EwUw7f76K5NbMhIUQF9nIPLRxO69pmacXBQnFZk3jqhOzDyO9cu31eF9WVGL+1\ntM/cAiUWLvDqsBh0iBiVgg==\n-----END PRIVATE KEY-----\n",
  "client_email": "nwayoogabyar@nway-oo-gabyar.iam.gserviceaccount.com",
  "client_id": "116049179394549158217",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/nwayoogabyar%40nway-oo-gabyar.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';
  final String sheetId = '18f8b-t2JAj-mjKxTprnRAdnxQFLFT0ahFbS97ZB1vug';
  late final Spreadsheet ss;

  initSheet() async {
    GSheets gsheet = GSheets(_credential);
    ss = await gsheet.spreadsheet(sheetId);
  }

  Future<void> getUserById(String userId) async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    List<String>? response =
        await usersSheet!.values.rowByKey(userId, fromColumn: 1);
    if (response != null) {
      Profile temp = Profile(
        id: response[0],
        userName: response[1],
        password: response[2],
        totalPoints: int.parse(response[3]),
        remainedPoints: int.parse(response[4]),
        leastLoginDate: response[5],
        supportedPostId: response[6],
        userAvatar: response[7],
        dailyActivity: response[8],
        userBio: response[9],
        certificate: response[10],
        level: int.parse(response[11]),
        headerImg: response[12],
        jackpotTicket: response.length < 14 ? 5 : int.parse(response[13]),
        prize: response.length < 15 ? 0 : int.parse(response[14]),
        wordPuzzleLevel: response.length < 16 ? 0 : int.parse(response[15]),
      );
      UserCredential.userProfile = temp;
      UserCredential.isNew = false;
      await UserCredential.setUserCredential();
    }
  }

  Future<void> getUserProfiles() async {
    List<Profile> profiles = [];
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    List<List<String>>? responses =
        await usersSheet!.values.allRows(fromRow: 2);
    for (int i = 0; i < responses.length; i++) {
      Profile temp = Profile(
        id: responses[i][0],
        userName: responses[i][1],
        password: responses[i][2],
        totalPoints: int.parse(responses[i][3]),
        remainedPoints: int.parse(responses[i][4]),
        leastLoginDate: responses[i][5],
        supportedPostId: responses[i][6],
        userAvatar: responses[i][7],
        dailyActivity: responses[i][8],
        userBio: responses[i][9],
        certificate: responses[i][10],
        level: int.parse(responses[i][11]),
        headerImg: responses[i][12],
        jackpotTicket:
            responses[i].length < 14 ? 5 : int.parse(responses[i][13]),
        prize: responses[i].length < 15 ? 0 : int.parse(responses[i][14]),
        wordPuzzleLevel:
            responses[i].length < 16 ? 0 : int.parse(responses[i][15]),
      );
      profiles.add(temp);
    }
    UserCredential.profiles = profiles;
  }

  addNewUser(String userName, String password) async {
    Profile profile = Profile(
      id: '',
      userName: userName,
      password: password,
      totalPoints: 0,
      remainedPoints: 0,
      leastLoginDate: DateTime.now().toString(),
      supportedPostId: 'null',
      userAvatar: './lib/image/Logo.png',
      dailyActivity: 'null',
      userBio: 'Tab to edit bio',
      certificate: '[]',
      level: 0,
      headerImg: './lib/image/headers/header_01.png',
      jackpotTicket: 5,
      prize: 0,
      wordPuzzleLevel: 0,
    );
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    List<String>? lastRow = await usersSheet!.values.lastRow();
    if (lastRow == null) {
      profile.id = 'NOG00001';
    } else {
      var id = lastRow[0];
      var serial = int.parse(id.substring(4));
      serial++;
      id = 'NOG${serial.toString().padLeft(5, "0")}';
      profile.id = id;
    }
    await usersSheet.values.appendRow(
      [
        profile.id,
        profile.userName,
        profile.password,
        profile.totalPoints,
        profile.remainedPoints,
        profile.leastLoginDate,
        profile.supportedPostId,
        profile.userAvatar,
        profile.dailyActivity,
        profile.userBio,
        profile.certificate,
        profile.level,
        profile.headerImg,
        profile.jackpotTicket,
        profile.prize,
        profile.wordPuzzleLevel,
      ],
    );
    UserCredential.userProfile = profile;
    await UserCredential.setUserCredential();
  }

  editUserBio(String userId, String bio) async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(userId, fromColumn: 10, [bio]);
  }

  editProfileHeader(String userId, String headerImg) async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(userId, fromColumn: 13, [headerImg]);
  }

  editUserSupport(String userId, String supportedId) async {
    if (supportedId == '') {
      supportedId = 'null';
    }
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(userId, fromColumn: 7, [supportedId]);
  }

  editPoints(String userId) async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    await usersSheet!.values.insertRowByKey(
      userId,
      fromColumn: 4,
      [
        UserCredential.userProfile.totalPoints,
        UserCredential.userProfile.remainedPoints,
      ],
    );
    usersSheet.values.insertRowByKey(
      userId,
      fromColumn: 9,
      [UserCredential.dailyActivity.toString()],
    );
  }

  editUserDailyActivity(String userId) async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(
      userId,
      fromColumn: 9,
      [UserCredential.dailyActivity.toString()],
    );
  }

  editLastLoginDate(String userId) async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(
      userId,
      fromColumn: 6,
      [DateTime.now().toString()],
    );
  }

  changeName(String userId, String newName) async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(
      userId,
      fromColumn: 2,
      [newName],
    );
  }

  changePassword(String userId, String newPassword) async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(
      userId,
      fromColumn: 3,
      [newPassword],
    );
  }

  editUserAvatar(String userId, String avatarLink) async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(
      userId,
      fromColumn: 8,
      [avatarLink],
    );
  }

  editJackpotTicket() async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(
      UserCredential.userProfile.id,
      fromColumn: 14,
      [UserCredential.userProfile.jackpotTicket],
    );
  }

  Future<void> editPrize() async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(
      UserCredential.userProfile.id,
      fromColumn: 15,
      [UserCredential.userProfile.prize],
    );
  }

  Future<void> editWordPuzzleLevel() async {
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    usersSheet!.values.insertRowByKey(
      UserCredential.userProfile.id,
      fromColumn: 16,
      [UserCredential.userProfile.wordPuzzleLevel],
    );
  }

  todayActiveUser() async {
    int activeUserCount = 0;
    List<Profile> users = [];
    String today = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    String daily = DateFormat('dd.MM.yyyy').format(DateTime.now());
    await initSheet();
    Worksheet? usersSheet = ss.worksheetByTitle('profiles');
    List<List<String>> records = await usersSheet!.values.allRows(fromRow: 2);

    for (int i = 0; i < records.length; i++) {
      users.add(
        Profile(
          id: records[i][0],
          userName: records[i][1],
          password: records[i][2],
          totalPoints: int.parse(records[i][3]),
          remainedPoints: int.parse(records[i][4]),
          leastLoginDate: records[i][5],
          supportedPostId: records[i][6],
          userAvatar: records[i][7],
          dailyActivity: records[i][8],
          userBio: records[i][9],
          certificate: records[i][10],
          level: int.parse(records[i][11]),
          headerImg: records[i][12],
          jackpotTicket: records[i].length < 14 ? 0 : int.parse(records[i][13]),
          prize: records[i].length < 15 ? 0 : int.parse(records[i][14]),
          wordPuzzleLevel:
              records[i].length < 16 ? 0 : int.parse(records[i][15]),
        ),
      );

      DateTime leastActiveDate = DateTime.fromMillisecondsSinceEpoch(
          ((double.parse(records[i][5]) - 25569) * 86400000).toInt(),
          isUtc: true);

      if (DateFormat('dd-MMM-yyyy').format(leastActiveDate) == today) {
        activeUserCount++;
      }
    }
    UserCredential.profiles = users;
    users.sort((a, b) => a.totalPoints.compareTo(b.totalPoints));
    UserCredential.topUsers = users.reversed.toList();
    Worksheet? dailySheet = ss.worksheetByTitle('daily');
    dailySheet!.values.insertRowByKey(daily, [activeUserCount, today]);
    return activeUserCount;
  }

  getDailyUser() async {
    await initSheet();
    Worksheet? dailySheet = ss.worksheetByTitle('daily');
    List<List<String>> responses = await dailySheet!.values.allRows();
    List<List<String>> reversedList = responses.reversed.toList();
    List<DailyUser> dailyUsers = [];
    double maxY = 0;
    for (int i = 0; i < 7; i++) {
      if (double.parse(reversedList[i][1]) > maxY) {
        maxY = double.parse(reversedList[i][1]);
      }
      dailyUsers.add(
        DailyUser(
          dateString: reversedList[i][0],
          activeUser: int.parse(reversedList[i][1]),
          recordedDate: reversedList[i][2],
          estIncome:
              reversedList[i].length < 5 ? 0 : double.parse(reversedList[i][4]),
        ),
      );
    }
    double complement = maxY % 10;
    complement = 10 - complement;
    maxY = maxY + complement;
    UserCredential.maxY = maxY;
    return dailyUsers.reversed.toList();
  }

  getPost() async {
    List<Post> posts = [];
    Set categories = <String>{};
    await initSheet();
    Worksheet? postsSheet = ss.worksheetByTitle('posts');
    List<List<String>> records = await postsSheet!.values.allRows(fromRow: 2);

    if (records.isNotEmpty) {
      for (int i = 0; i < records.length; i++) {
        posts.add(
          Post(
            postId: records[i][0],
            timestamp: records[i][1],
            mmTitle: records[i][2],
            mmDescription: records[i][3],
            enTitle: records[i][4],
            enDescription: records[i][5],
            coverPhotoUrl: records[i][6],
            author: records[i][7],
            category: records[i][8],
            genre: records[i][9],
            credit: records[i].length < 11 ? '' : records[i][10],
            likedUserId: records[i].length < 12 ? '' : records[i][11],
          ),
        );
        categories.add(records[i][8]);
      }
    }
    UserCredential.categories = categories.toList() as List<String>;
    UserCredential.posts = posts.reversed.toList();
  }

  Future<void> editPostLikedIds(String postId, bool isLiked) async {
    String likedIds = '';
    await initSheet();
    Worksheet? postsSheet = ss.worksheetByTitle('posts');
    List<String>? record =
        await postsSheet!.values.rowByKey(postId, fromColumn: 1);
    if (record != null) {
      likedIds = record.length < 12 ? "" : record[11];
      if (isLiked) {
        if (!likedIds.contains(UserCredential.userProfile.id)) {
          likedIds = likedIds + UserCredential.userProfile.id;
        }
      } else {
        likedIds = likedIds.replaceAll(UserCredential.userProfile.id, '');
      }
      await postsSheet.values
          .insertRowByKey(postId, [likedIds], fromColumn: 12);
    }
  }

  getAudioFile() async {
    await initSheet();
    Worksheet? audioSheet = ss.worksheetByTitle('audios');
    List<List<String>>? records = await audioSheet!.values.allRows(fromRow: 2);
    List<AudioFile> audioFiles = [];
    Set<String> audioCategory = {};
    for (int i = 0; i < records.length; i++) {
      audioFiles.add(
        AudioFile(
          audioId: records[i][0],
          timeStamp: records[i][1],
          audioTitleMM: records[i][2],
          audioTitleEN: records[i][3],
          audioCategory: records[i][4],
          artist: records[i][5],
          audioGenre: records[i][6],
          audioUrl: records[i][7],
          credit: records[i][8],
          playlist: records[i].length < 10 ? '' : records[i][9],
          coverPhoto: records[i].length < 11 ? '' : records[i][10],
          playCount: int.parse(records[i][11]),
          duration: records[i][12],
        ),
      );
      audioCategory.add(records[i][4]);
    }
    UserCredential.audioCategories = audioCategory.toList();
    UserCredential.audios = audioFiles.reversed.toList();
  }

  increastAudioPlayCount(String audioId) async {
    int playCount = 0;
    for (int i = 0; i < UserCredential.audios.length; i++) {
      if (UserCredential.audios[i].audioId == audioId) {
        playCount = UserCredential.audios[i].playCount =
            UserCredential.audios[i].playCount + 1;
        break;
      }
    }
    await initSheet();
    Worksheet? audioSheet = ss.worksheetByTitle('audios');
    await audioSheet!.values
        .insertRowByKey(audioId, [playCount], fromColumn: 12);
  }

  setAudioDuration(String audioId, String duration) async {
    for (int i = 0; i < UserCredential.audios.length; i++) {
      if (UserCredential.audios[i].audioId == audioId) {
        UserCredential.audios[i].duration = duration;
        break;
      }
    }
    await initSheet();
    Worksheet? audioSheet = ss.worksheetByTitle('audios');
    await audioSheet!.values
        .insertRowByKey(audioId, [duration], fromColumn: 13);
  }

  Future<List<Comment>> getCommentsByPostId(String postId) async {
    List<Comment> comments = [];
    await initSheet();
    Worksheet? commentsSheet = ss.worksheetByTitle('comments');
    List<List<String>> records =
        await commentsSheet!.values.allRows(fromRow: 2);

    if (records.isNotEmpty) {
      for (int i = 0; i < records.length; i++) {
        if (records[i][3] == postId) {
          comments.add(
            Comment(
              commentId: records[i][0],
              timestamp: records[i][1],
              comment: records[i][2],
              postId: records[i][3],
              userId: records[i][4],
            ),
          );
        }
      }
    }

    return comments;
  }

  addNewComment(Comment userComment) async {
    String commentId = '';
    await initSheet();
    Worksheet? commentsSheet = ss.worksheetByTitle('comments');
    List<String>? lastRow = await commentsSheet!.values.lastRow();
    if (lastRow == null || lastRow[0] == 'commentId') {
      commentId = 'CM000001';
    } else {
      var id = lastRow[0];
      var serial = int.parse(id.substring(3));
      serial++;
      id = 'CM${serial.toString().padLeft(6, "0")}';
      commentId = id;
    }
    await commentsSheet.values.appendRow(
      [
        commentId,
        DateTime.now().toString(),
        userComment.comment,
        userComment.postId,
        userComment.userId,
        "***",
        "***",
      ],
    );
  }

  deleteComment(String commentId) async {
    await initSheet();
    Worksheet? commentSheet = ss.worksheetByTitle('comments');
    int index = await commentSheet!.values.rowIndexOf(commentId);
    if (index == -1) return;
    commentSheet.deleteRow(index);
  }

  getArticles() async {
    await initSheet();
    Worksheet? articleSheet = ss.worksheetByTitle('articles');
    List<List<String>>? responses =
        await articleSheet!.values.allRows(fromRow: 2);
    List<Article> articles = [];
    Set<String> categories = {'All'};
    for (int i = 0; i < responses.length; i++) {
      articles.add(
        Article(
          id: responses[i][0],
          timestamp: responses[i][1],
          titleMM: responses[i][2],
          contentMM: responses[i][3],
          titleEN: responses[i][4],
          contentEN: responses[i][5],
          category: responses[i][6],
          author: responses[i][7],
          source: responses[i][8],
          coverPhoto: responses[i].length > 9
              ? responses[i][9]
              : 'https://i.ibb.co/NsG79d3/Notes-6.png',
        ),
      );
      categories.add(responses[i][6]);
    }
    UserCredential.articles = articles.reversed.toList();
    UserCredential.articleCategories = categories.toList();
  }

  getBlogPost() async {
    await initSheet();
    Worksheet? blogSheet = ss.worksheetByTitle('blogPosts');
    List<List<String>>? responses = await blogSheet!.values.allRows(fromRow: 2);
    List<BlogPost> posts = [];
    for (int i = 0; i < responses.length; i++) {
      posts.add(
        BlogPost(
          id: responses[i][0],
          timestamp: responses[i][1],
          userId: responses[i][2],
          post: responses[i][3],
          likedId: responses[i].length < 5 ? '' : responses[i][4],
        ),
      );
    }
    UserCredential.blogPosts = posts.reversed.toList();
  }

  addBlogPost(BlogPost post) async {
    await initSheet();
    Worksheet? blogSheet = ss.worksheetByTitle('blogPosts');
    List<String>? response = await blogSheet!.values.lastRow();
    String id = '';
    if (response == null || response[0] == 'id') {
      id = 'BPOST00001';
    } else {
      String temp = response[0];
      int serial = int.parse(temp.substring(5));
      serial++;
      id = 'BPOST${serial.toString().padLeft(5, "0")}';
    }
    blogSheet.values.appendRow([
      id,
      post.timestamp,
      post.userId,
      post.post,
      post.likedId,
    ]);
  }

  editBlogPost(BlogPost post) async {
    await initSheet();
    Worksheet? blogSheet = ss.worksheetByTitle('blogPosts');
    blogSheet!.values.insertRowByKey(post.id, [post.post], fromColumn: 4);
  }

  deleteBlogPost(BlogPost post) async {
    await initSheet();
    Worksheet? blogSheet = ss.worksheetByTitle('blogPosts');
    int index = await blogSheet!.values.rowIndexOf(post.id);
    await blogSheet.deleteRow(index);
  }

  editBlogLike(String id, bool isLike) async {
    await initSheet();
    Worksheet? blogSheet = ss.worksheetByTitle('blogPosts');
    List<String>? data = await blogSheet!.values.rowByKey(id);
    String likedId = '';
    String userId = UserCredential.userProfile.id;
    if (data != null) {
      data.length < 4 ? likedId : likedId = data[3];
      if (isLike) {
        likedId.contains(userId) ? likedId : likedId = likedId + userId;
      } else {
        likedId = likedId.replaceAll(userId, '');
      }
    }
    blogSheet.values.insertRowByKey(
      id,
      [likedId],
      fromColumn: 5,
    );
  }

  getBlogComment() async {
    await initSheet();
    Worksheet? blogCommentSheet = ss.worksheetByTitle('blogComments');
    List<List<String>>? responses =
        await blogCommentSheet!.values.allRows(fromRow: 2);
    List<BlogComment> comments = [];
    List<BlogComment> replyComments = [];
    List<String> commentedBlogIds = [];
    for (int i = 0; i < responses.length; i++) {
      commentedBlogIds.add(responses[i][4]);
      if (responses[i].length < 6) {
        comments.add(
          BlogComment(
            id: responses[i][0],
            timestamp: responses[i][1],
            comment: responses[i][2],
            userId: responses[i][3],
            blogId: responses[i][4],
          ),
        );
      } else {
        replyComments.add(
          BlogComment(
            id: responses[i][0],
            timestamp: responses[i][1],
            comment: responses[i][2],
            userId: responses[i][3],
            blogId: responses[i][4],
            replyToId: responses[i][5],
          ),
        );
      }
    }
    UserCredential.blogComments = comments;
    UserCredential.replyBlogComments = replyComments;
    UserCredential.commentedBlogIds = commentedBlogIds;
  }

  addBlogComment(BlogComment comment) async {
    await initSheet();
    Worksheet? blogCommentSheet = ss.worksheetByTitle('blogComments');
    List<String>? response = await blogCommentSheet!.values.lastRow();
    String id = '';
    if (response == null || response[0] == 'id') {
      id = 'BCMD00001';
    } else {
      String temp = response[0];
      int serial = int.parse(temp.substring(4));
      serial++;
      id = 'BCMD${serial.toString().padLeft(5, "0")}';
    }
    await blogCommentSheet.values.appendRow([
      id,
      comment.timestamp,
      comment.comment,
      comment.userId,
      comment.blogId,
      comment.replyToId,
    ]);
  }

  editBlogComment(BlogComment comment) async {
    await initSheet();
    Worksheet? blogCommentSheet = ss.worksheetByTitle('blogComments');
    blogCommentSheet!.values.insertRowByKey(
      comment.id,
      [comment.comment],
      fromColumn: 3,
    );
  }

  deleteBlogComment(BlogComment comment) async {
    await initSheet();
    Worksheet? blogCommentSheet = ss.worksheetByTitle('blogComments');
    int index = await blogCommentSheet!.values.rowIndexOf(comment.id);
    await blogCommentSheet.deleteRow(index);
  }

  getStoryPhoto() async {
    List<StoryPhoto> stories = [];
    await initSheet();
    Worksheet? storyPhotoSheet = ss.worksheetByTitle('storyPhoto');
    List<List<String>>? responses =
        await storyPhotoSheet!.values.allRows(fromRow: 1, fill: true);
    if (responses.isNotEmpty) {
      for (int i = 1; i < responses.length; i++) {
        stories.add(
          StoryPhoto(
            userId: responses[i][0],
            photoUrl: responses[i][1],
            timestamp: responses[i][2],
            likedIds: responses[i][3],
          ),
        );
      }
    }
    stories.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    UserCredential.storyPhotos = stories.reversed.toList();
  }

  addStoryPhoto(StoryPhoto newStoryPhoto) async {
    await initSheet();
    Worksheet? storyPhotoSheet = ss.worksheetByTitle('storyPhoto');
    await storyPhotoSheet!.values.insertRowByKey(
      newStoryPhoto.userId,
      [
        newStoryPhoto.photoUrl,
        newStoryPhoto.timestamp,
        '',
      ],
    );
    UserCredential.storyPhotos
        .removeWhere((storyPhoto) => storyPhoto.userId == newStoryPhoto.userId);

    UserCredential.storyPhotos.insert(0, newStoryPhoto);
  }

  addViewedId(String storyUserId, String likedUserId) async {
    await initSheet();
    Worksheet? storyPhotoSheet = ss.worksheetByTitle('storyPhoto');
    List<String>? response = await storyPhotoSheet!.values.rowByKey(
      storyUserId,
      fromColumn: 1,
    );
    if (response != null) {
      String temp = response.length < 4 ? '' : response[3];
      temp = temp + likedUserId;
      await storyPhotoSheet.values.insertRowByKey(
        storyUserId,
        [temp],
        fromColumn: 4,
      );
      int index = UserCredential.storyPhotos
          .indexWhere((element) => element.userId == storyUserId);
      UserCredential.storyPhotos[index].likedIds = temp;
    }
  }

  deleteStoryPhoto(String userId) async {
    await initSheet();
    Worksheet? storyPhotoSheet = ss.worksheetByTitle('storyPhoto');
    int index = await storyPhotoSheet!.values.rowIndexOf(userId);
    await storyPhotoSheet.deleteRow(index);
    UserCredential.storyPhotos
        .removeWhere((storyPhoto) => storyPhoto.userId == userId);
  }

  getQuotes() async {
    await initSheet();
    Worksheet? quotesSheet = ss.worksheetByTitle('quotes');
    List<String>? quotesImgLink = await quotesSheet!.values.column(1);
    UserCredential.ytchannelLinks = await quotesSheet.values.column(2);
    return quotesImgLink;
  }

  Future<List<List<String>>> getWordPuzzle() async {
    await initSheet();
    Worksheet? gameSheet = ss.worksheetByTitle('game');
    List<List<String>> words = await gameSheet!.values.allRows(fromRow: 2);
    return words;
  }

  Future<List<PuzzleImage>> getPuzzleImages() async {
    List<PuzzleImage> puzzleImages = [];
    await initSheet();
    Worksheet? puzzleSheet = ss.worksheetByTitle('puzzle');
    List<List<String>> responses = await puzzleSheet!.values.allRows();
    if (responses.isNotEmpty) {
      for (int i = 0; i < responses.length; i++) {
        PuzzleImage img = PuzzleImage(
          img: responses[i][0],
          puzzleImages: [
            {'index': 0, 'img': responses[i][1]},
            {'index': 1, 'img': responses[i][2]},
            {'index': 2, 'img': responses[i][3]},
            {'index': 3, 'img': responses[i][4]},
            {'index': 4, 'img': responses[i][5]},
            {'index': 5, 'img': responses[i][6]},
            {'index': 6, 'img': responses[i][7]},
            {'index': 7, 'img': responses[i][8]},
            {'index': 8, 'img': responses[i][9]},
            {'index': 9, 'img': responses[i][10]},
            {'index': 10, 'img': responses[i][11]},
            {'index': 11, 'img': responses[i][12]},
            {'index': 12, 'img': responses[i][13]},
            {'index': 13, 'img': responses[i][14]},
            {'index': 14, 'img': responses[i][15]},
            {'index': 15, 'img': responses[i][16]},
          ],
        );
        puzzleImages.add(img);
      }
    }
    return puzzleImages;
  }

  getVideoFile() async {
    await initSheet();
    Worksheet? videoSheet = ss.worksheetByTitle('videos');
    List<List<String>>? records = await videoSheet!.values.allRows(fromRow: 2);

    List<VideoFile> videoFiles = [];

    for (int i = 0; i < records.length; i++) {
      videoFiles.add(VideoFile(
        videoId: records[i][0],
        videoLink: records[i][1],
        videTitle: records[i][2],
        likedIds: records[i][3],
        timestamp: records[i][4],
      ));
    }

    UserCredential.videos = videoFiles.reversed.toList();
  }

  editVideoLike(String videoId, String likedIds) async {
    await initSheet();
    Worksheet? videosSheet = ss.worksheetByTitle('videos');
    videosSheet!.values.insertRowByKey(videoId, fromColumn: 4, [likedIds]);
  }

  Future<void> sendFile(
      String title, String description, String fileUrl) async {
    await initSheet();
    Worksheet? filesSheet = ss.worksheetByTitle('files');
    filesSheet!.values.appendRow([title, description, fileUrl]);
  }

  Future<String> getInfo(String infoKey) async {
    await initSheet();
    Worksheet? infoSheet = ss.worksheetByTitle('info');
    List<String>? response = await infoSheet!.values.rowByKey(infoKey);
    String info = response == null ? "" : response[0];
    return info;
  }
}
