import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/controller/dateformatter.dart';
import 'package:nwayoogabyar/data/ad.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/blogcomment.dart';
import 'package:nwayoogabyar/model/blogpost.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/addblogpost.dart';
import 'package:nwayoogabyar/view/fullimageview.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewBlogPost extends StatefulWidget {
  final BlogPost post;
  const ViewBlogPost({super.key, required this.post});

  @override
  State<ViewBlogPost> createState() => _ViewBlogPostState();
}

class _ViewBlogPostState extends State<ViewBlogPost> {
  FocusNode commentFocus = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLike = false;
  List<BlogComment> comments = [];
  List<BlogComment> repliedComments = [];
  bool isLoading = true;
  bool showImg = false;

  String postText = '';
  String imageText = '';
  String replyToId = '';

  getBlogComments() {
    setState(() {
      isLoading = true;
    });
    comments = [];
    repliedComments = [];
    for (int i = 0; i < UserCredential.blogComments.length; i++) {
      if (UserCredential.blogComments[i].blogId == widget.post.id) {
        comments.add(UserCredential.blogComments[i]);
      }
    }
    for (int i = 0; i < UserCredential.replyBlogComments.length; i++) {
      if (UserCredential.replyBlogComments[i].blogId == widget.post.id) {
        repliedComments.add(UserCredential.replyBlogComments[i]);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  editComment(BuildContext mainContext, BlogComment comment) {
    GlobalKey<FormState> cmdFormKey = GlobalKey<FormState>();
    TextEditingController editCommentText = TextEditingController();
    FocusNode editCmdBox = FocusNode();
    showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        shape: DesignProvider.getDialogBoxShape(10),
        title: const Text('Edit'),
        content: Form(
          key: cmdFormKey,
          child: TextFormField(
            controller: editCommentText..text = comment.comment,
            focusNode: editCmdBox,
            validator: (value) {
              if (value == '' || value == null) {
                return 'Comment cannot be empty.';
              } else {
                return null;
              }
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                setState(() {
                  isLoading = true;
                });
                await API().deleteBlogComment(comment);
                UserCredential.blogComments.removeWhere(
                  (element) => element.id == comment.id,
                );
                getBlogComments();
                setState(() {
                  isLoading = false;
                });
              } on Exception catch (e) {
                setState(() {
                  isLoading = false;
                });
                if (mounted) {
                  showDialog(
                    context: mainContext,
                    builder: (context) => AlertDialog(
                      shape: DesignProvider.getDialogBoxShape(10),
                      title: const Text('Error!'),
                      content: const Text('Error occour! Try later.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
          ElevatedButton(
              onPressed: () async {
                String oldComment = comment.comment;
                if (cmdFormKey.currentState!.validate()) {
                  editCmdBox.unfocus();
                  comment.comment = editCommentText.text;
                  Navigator.pop(context);
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    await API().editBlogComment(comment);
                    int index = -1;
                    for (int i = 0;
                        i < UserCredential.blogComments.length;
                        i++) {
                      if (UserCredential.blogComments[i].id == comment.id) {
                        index = i;
                        break;
                      }
                    }
                    UserCredential.blogComments[index] = comment;
                    getBlogComments();
                    setState(() {
                      isLoading = false;
                    });
                  } on Exception catch (e) {
                    if (mounted) {
                      showDialog(
                        context: mainContext,
                        builder: (context) => AlertDialog(
                          shape: DesignProvider.getDialogBoxShape(10),
                          title: const Text('Error!'),
                          content: const Text('Error occour! Try later.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                    comment.comment = oldComment;
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  List<BlogComment> getReplyComments(String commentId) {
    List<BlogComment> temp = [];
    for (int i = 0; i < repliedComments.length; i++) {
      if (repliedComments[i].replyToId == commentId) {
        temp.add(repliedComments[i]);
      }
    }
    return temp;
  }

  BannerAd? bannerAd;
  bool isBannaAdLoaded = false;

  void loadAd() {
    bannerAd = BannerAd(
      adUnitId: AdHelper.topBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannaAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    isLike = UserCredential.isBlogLike(
        widget.post.id, UserCredential.userProfile.id);
    int lenght = widget.post.post.length;
    int index = widget.post.post.indexOf('![img]');

    if (index > -1) {
      postText = widget.post.post.substring(0, index - 2);
      imageText = widget.post.post.substring(index + 7, lenght - 1);
    } else {
      postText = widget.post.post;
    }
    getBlogComments();
    super.initState();
  }

  @override
  void dispose() {
    commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 1,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow,
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
        centerTitle: true,
        title: Text(UserCredential.getUserName(widget.post.userId)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              isBannaAdLoaded
                  ? Container(
                      color: Theme.of(context).colorScheme.background,
                      width: double.infinity,
                      height: bannerAd!.size.height.toDouble(),
                      alignment: Alignment.center,
                      child: AdWidget(ad: bannerAd!),
                    )
                  : const SizedBox(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: getAvatorImg(
                              UserCredential.getUserAvatar(widget.post.userId)),
                        ),
                        title: Text(
                          UserCredential.getUserName(widget.post.userId),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          DateFormatter.getPostedAge(
                              double.parse(widget.post.timestamp)),
                          style: const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          top: 0,
                          left: 10,
                          right: 10,
                          bottom: 10,
                        ),
                        child: Linkify(
                          onOpen: (link) async {
                            if (!await launchUrl(Uri.parse(link.url),
                                mode: LaunchMode.externalApplication)) {
                              throw Exception('Could not launch ${link.url}');
                            }
                          },
                          text: postText,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      imageText == ''
                          ? const SizedBox()
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullImageView(
                                        imgUrl: imageText,
                                      ),
                                    ));
                              },
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                margin: const EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(imageText),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                      Container(
                        width: double.infinity,
                        height: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) =>
                            commentCard(comments[index]),
                      ),
                    ],
                  ),
                ),
              ),
              commentBar(),
            ],
          ),
          isLoading
              ? Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.shadow,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Updating....')
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  getAvatorImg(String imgLink) {
    return imgLink.startsWith('http')
        ? NetworkImage(imgLink)
        : AssetImage(imgLink);
  }

  Container reactRow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.shadow,
            style: BorderStyle.solid,
            width: 0.4,
          ),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.shadow,
            style: BorderStyle.solid,
            width: 0.4,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isLike = !isLike;
              });
            },
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: FaIcon(
                      isLike
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      size: 16,
                      color: isLike ? Colors.pink : Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: " Like",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => commentFocus.requestFocus(),
            child: RichText(
              text: TextSpan(
                children: [
                  const WidgetSpan(
                    child: FaIcon(
                      FontAwesomeIcons.comment,
                      size: 16,
                    ),
                  ),
                  TextSpan(
                    text: " Comment",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "## ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const WidgetSpan(
                  child: FaIcon(
                    FontAwesomeIcons.chartColumn,
                    size: 16,
                  ),
                ),
                TextSpan(
                  text: " View",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
          widget.post.userId == UserCredential.userProfile.id
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBlogPost(
                            isAddNew: false,
                            post: widget.post,
                          ),
                        )).then((value) => Navigator.pop(context));
                  },
                  child: const FaIcon(
                    FontAwesomeIcons.penToSquare,
                    size: 16,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Container commentBar() {
    TextEditingController comment = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.shadow,
            width: 0.4,
          ),
        ),
      ),
      width: double.infinity,
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: comment,
          focusNode: commentFocus,
          textAlignVertical: TextAlignVertical.top,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(
              left: 4,
              bottom: 4,
            ),
            border: const OutlineInputBorder(),
            hintText: 'Type your comment...',
            prefixText: replyToId.isEmpty ? null : replyToId,
            suffix: IconButton(
              onPressed: () async {
                List<BlogComment> oldComments = [];
                for (int i = 0; i < comments.length; i++) {
                  oldComments.add(comments[i]);
                }
                List<BlogComment> oldReplyComments = [];
                for (int i = 0; i < repliedComments.length; i++) {
                  oldReplyComments.add(repliedComments[i]);
                }
                if (formKey.currentState!.validate()) {
                  String cmd = comment.text;
                  comment.text = '';
                  commentFocus.unfocus();
                  BlogComment newComment = BlogComment(
                    id: 'id',
                    timestamp: DateTime.now().toString(),
                    comment: cmd,
                    userId: UserCredential.userProfile.id,
                    blogId: widget.post.id,
                    replyToId: replyToId,
                  );

                  if (replyToId.isEmpty) {
                    comments.add(newComment);
                  } else {
                    repliedComments.add(newComment);
                  }
                  setState(() {
                    comments;
                    repliedComments;
                  });
                  try {
                    await API().addBlogComment(newComment);
                    await API().getBlogComment();
                    getBlogComments();
                    setState(() {});
                  } on Exception catch (e) {
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: DesignProvider.getDialogBoxShape(10),
                          title: const Text("error"),
                          content:
                              const Text("Server Error Occour! Try again."),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  comments = oldComments;
                                  repliedComments = oldReplyComments;
                                  setState(() {
                                    comments;
                                    repliedComments;
                                  });
                                },
                                child: const Text('OK')),
                          ],
                        ),
                      );
                    }
                  }
                }
              },
              icon: const Icon(EneftyIcons.send_3_outline),
            ),
          ),
          onTapOutside: (event) {
            setState(() {
              replyToId = '';
            });
            commentFocus.unfocus();
          },
          validator: (value) {
            if (value == null || value == '') {
              return 'Write your comment.';
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  Container commentCard(BlogComment comment) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
        right: 5,
        top: 5,
        left: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                getAvatorImg(UserCredential.getUserAvatar(comment.userId)),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 5),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      UserCredential.getUserName(comment.userId),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 5, left: 5),
                    child: Linkify(
                      onOpen: (link) async {
                        if (!await launchUrl(Uri.parse(link.url),
                            mode: LaunchMode.externalApplication)) {
                          throw Exception('Could not launch ${link.url}');
                        }
                      },
                      text: comment.comment,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14,
                        color: comment.id == 'id'
                            ? Theme.of(context).colorScheme.shadow
                            : Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          child: comment.id == 'id'
                              ? const Text('...')
                              : Text(
                                  DateFormatter.getPostedAge(
                                    double.parse(comment.timestamp),
                                  ),
                                ),
                        ),
                        const Expanded(child: SizedBox()),
                        comment.userId == UserCredential.userProfile.id &&
                                comment.id != 'id'
                            ? SizedBox(
                                child: GestureDetector(
                                  onTap: () {
                                    editComment(context, comment);
                                  },
                                  child: const Text(
                                    'Edit',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              )
                            : Container(),
                        const SizedBox(width: 10),
                        comment.id != 'id'
                            ? SizedBox(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      replyToId = comment.id;
                                    });
                                    commentFocus.requestFocus();
                                  },
                                  child: const Text(
                                    'Reply',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  getReplyComments(comment.id).isEmpty
                      ? Container()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: getReplyComments(comment.id).length,
                          itemBuilder: (context, index) {
                            return replyCommentCard(
                                getReplyComments(comment.id)[index]);
                          }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget replyCommentCard(BlogComment comment) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
        right: 5,
        top: 5,
        left: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                getAvatorImg(UserCredential.getUserAvatar(comment.userId)),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 5),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      UserCredential.getUserName(comment.userId),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 2),
                    child: comment.id == 'id'
                        ? const Text('...')
                        : Text(
                            DateFormatter.getPostedAge(
                                double.parse(comment.timestamp)),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 5, top: 5),
                    child: Linkify(
                      onOpen: (link) async {
                        if (!await launchUrl(Uri.parse(link.url),
                            mode: LaunchMode.externalApplication)) {
                          throw Exception('Could not launch ${link.url}');
                        }
                      },
                      text: comment.comment,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: comment.id == 'id'
                            ? Theme.of(context).colorScheme.shadow
                            : Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      comment.userId == UserCredential.userProfile.id &&
                              comment.id != 'id'
                          ? SizedBox(
                              child: GestureDetector(
                                onTap: () {
                                  editComment(context, comment);
                                },
                                child: const Text(
                                  'Edit',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
