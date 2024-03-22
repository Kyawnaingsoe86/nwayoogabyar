import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/blogpost.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AddBlogPost extends StatefulWidget {
  final BlogPost? post;
  final bool isAddNew;
  const AddBlogPost({super.key, this.post, required this.isAddNew});

  @override
  State<AddBlogPost> createState() => _AddBlogPostState();
}

class _AddBlogPostState extends State<AddBlogPost> {
  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController postController = TextEditingController();
  TextEditingController imgLinkController = TextEditingController();
  FocusNode postFocusNode = FocusNode();
  FocusNode imageFocusNode = FocusNode();
  String postText = '';
  String imageText = '';
  String imageLink = '';

  getPostText() {
    if (widget.post != null) {
      int lenght = widget.post!.post.length;
      int index = widget.post!.post.indexOf('![img]');

      if (index > -1) {
        postText = widget.post!.post.substring(0, index - 2);
        imageLink = widget.post!.post.substring(index + 7, lenght - 1);
      } else {
        postText = widget.post!.post;
      }
    }
  }

  deleteBlogPostComment(BlogPost post) async {
    for (int i = UserCredential.blogComments.length - 1; i >= 0; i--) {
      if (UserCredential.blogComments[i].blogId == post.id) {
        try {
          await API().deleteBlogComment(UserCredential.blogComments[i]);
          UserCredential.blogComments.removeAt(i);
        } on Exception catch (e) {
          Timer(const Duration(seconds: 3), () {
            deleteBlogPostComment(post);
          });
        }
      }
    }
    for (int i = UserCredential.replyBlogComments.length - 1; i >= 0; i--) {
      if (UserCredential.replyBlogComments[i].blogId == post.id) {
        try {
          await API().deleteBlogComment(UserCredential.replyBlogComments[i]);
          UserCredential.replyBlogComments.removeAt(i);
        } on Exception catch (e) {
          Timer(const Duration(seconds: 3), () {
            deleteBlogPostComment(post);
          });
        }
      }
    }
  }

  @override
  void initState() {
    getPostText();
    super.initState();
  }

  @override
  void dispose() {
    postController.dispose();
    imgLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 1,
        elevation: 1,
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
        title: const Text('Write post'),
        actions: [
          GestureDetector(
            onTap: () async {
              if (formKey.currentState!.validate()) {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                setState(() {
                  isLoading = true;
                });
                if (widget.post == null) {
                  BlogPost post = BlogPost(
                    id: 'id',
                    timestamp: DateTime.now().toString(),
                    userId: UserCredential.userProfile.id,
                    post: "$postText $imageText",
                    likedId: '',
                  );

                  try {
                    await API().addBlogPost(post);
                  } on Exception catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: DesignProvider.getDialogBoxShape(10),
                          title: const Text('Error!'),
                          content: const Text('Error occour. Try again later.'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'))
                          ],
                        ),
                      );
                    }
                  }
                } else {
                  BlogPost post = widget.post!;
                  post.post = "$postText $imageText";
                  try {
                    int index = UserCredential.blogPosts
                        .indexWhere((element) => element.id == post.id);
                    UserCredential.blogPosts[index] = post;
                    await API().editBlogPost(post);
                  } on Exception catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: DesignProvider.getDialogBoxShape(10),
                          title: const Text('Error!'),
                          content: const Text('Error occour. Try again later.'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'))
                          ],
                        ),
                      );
                    }
                  }
                }

                await API().getBlogPost();
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: Container(
              width: 90,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              child: Text(
                widget.isAddNew ? 'POST' : 'SAVE',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    backgroundImage: getImage(
                      UserCredential.getUserAvatar(
                          UserCredential.userProfile.id),
                    ),
                  ),
                  title: Text(
                    UserCredential.getUserName(UserCredential.userProfile.id),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Add New Post',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: postController..text = postText,
                    focusNode: postFocusNode,
                    maxLines: 8,
                    maxLength: 600,
                    decoration: const InputDecoration(
                      hintText: 'Write your feeling....',
                      contentPadding: EdgeInsets.all(10),
                    ),
                    validator: (value) {
                      if (value == null || value == '') {
                        return 'Please writer your feeling.';
                      } else {
                        postText = postController.text;
                        return null;
                      }
                    },
                    onTapOutside: (event) {
                      postFocusNode.unfocus();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: imgLinkController..text = imageLink,
                    focusNode: imageFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Image Link....',
                      contentPadding: EdgeInsets.all(10),
                      errorMaxLines: 2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value != '') {
                        if (!value.startsWith('http')) {
                          return 'url must be started with http';
                        } else if (!value.endsWith('jpg') &&
                            !value.endsWith('jpeg') &&
                            !value.endsWith('png') &&
                            !value.endsWith('gif') &&
                            !value.endsWith('bmp')) {
                          return 'unsupported image format. only support jpg, jpeg, gif, png, bmp';
                        } else {
                          imageLink = imgLinkController.text;
                          imageText = '\n\n![img](${imgLinkController.text})';
                          return null;
                        }
                      } else {
                        return null;
                      }
                    },
                    onTapOutside: (event) {
                      imageFocusNode.unfocus();
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    launchUrlString(
                      'https://postimages.org/',
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: const Text('Upload Image'),
                ),
                const Text(
                  'If you do not have image link. You can upload image by clicking "Upload Image" and copy direct link and use it as image link.',
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      widget.isAddNew
                          ? Container()
                          : ElevatedButton.icon(
                              style: ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  await API().deleteBlogPost(widget.post!);
                                  UserCredential.blogPosts.removeWhere(
                                    (element) => element.id == widget.post!.id,
                                  );

                                  await deleteBlogPostComment(widget.post!);
                                  await API().getBlogPost();
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                } on Exception catch (e) {
                                  if (mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: DesignProvider.getDialogBoxShape(
                                            10),
                                        title: const Text('Error!!'),
                                        content: const Text(
                                            'Server error occour. Please try again later.'),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const FaIcon(FontAwesomeIcons.trash),
                              label: const Text('Delete'),
                            ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ))
            : Container(),
      ]),
    );
  }

  getImage(String imgLink) {
    return imgLink.startsWith('http')
        ? NetworkImage(imgLink)
        : AssetImage(imgLink);
  }
}
