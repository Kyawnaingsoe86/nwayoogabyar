import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/storyphoto.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UploadStoryPhoto extends StatefulWidget {
  const UploadStoryPhoto({super.key});

  @override
  State<UploadStoryPhoto> createState() => _UploadStoryPhotoState();
}

class _UploadStoryPhotoState extends State<UploadStoryPhoto> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  GlobalKey<FormState> textFormKey = GlobalKey<FormState>();
  TextEditingController textController = TextEditingController();
  FocusNode textFocusNode = FocusNode();

  bool isLoading = false;
  bool isPhotoStory = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                storyTypeSelectionTab(context),
                isPhotoStory
                    ? photoUploadWidget(context)
                    : textUploadWidget(context),
              ],
            ),
          ),
          isLoading
              ? const LoadingPage(
                  title: 'Upload Story',
                  icon: EneftyIcons.direct_send_outline,
                  info: 'Uploading...',
                )
              : Container(),
        ],
      ),
    );
  }

  SizedBox storyTypeSelectionTab(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isPhotoStory = true;
              });
            },
            child: Container(
              width: 120,
              alignment: Alignment.center,
              decoration: isPhotoStory
                  ? BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      border: Border(
                        bottom: BorderSide(
                          width: 3,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
              child: const Text('PHOTO STORY'),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isPhotoStory = false;
              });
            },
            child: Container(
              width: 120,
              alignment: Alignment.center,
              decoration: !isPhotoStory
                  ? BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      border: Border(
                        bottom: BorderSide(
                          width: 3,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
              child: const Text('TEXT STORY'),
            ),
          ),
        ],
      ),
    );
  }

  Widget photoUploadWidget(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          EneftyIcons.gallery_add_outline,
          color: Theme.of(context).colorScheme.secondary,
          size: 150,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          child: Text(
            'YOUR STORY PHOTO',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Enter Photo Url',
                      errorMaxLines: 2,
                      contentPadding: EdgeInsets.only(left: 5),
                    ),
                    validator: (value) {
                      if (value == '' || value == null) {
                        return 'url cannot be empty';
                      } else if (!value.startsWith('http')) {
                        return 'url must be started with http';
                      } else if (!value.endsWith('jpg') &&
                          !value.endsWith('jpeg') &&
                          !value.endsWith('png') &&
                          !value.endsWith('gif') &&
                          !value.endsWith('bmp')) {
                        return 'unsupported image format. only support jpg, jpeg, gif, png, bmp';
                      } else {
                        return null;
                      }
                    },
                    onTapOutside: (event) {
                      focusNode.unfocus();
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      StoryPhoto storyPhoto = StoryPhoto(
                        userId: UserCredential.userProfile.id,
                        photoUrl: controller.text,
                        timestamp: DateTime.now().toString(),
                        likedIds: '',
                      );
                      await API().addStoryPhoto(storyPhoto);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } on Exception catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: DesignProvider.getDialogBoxShape(10),
                            title: const Text('Error'),
                            content: const Text('Error occour, try again.'),
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
                },
                icon: Icon(
                  EneftyIcons.direct_send_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            launchUrlString(
              'https://postimages.org/',
              mode: LaunchMode.externalApplication,
            );
          },
          child: const Text('Upload Image'),
        ),
      ],
    );
  }

  Widget textUploadWidget(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          EneftyIcons.text_block_outline,
          color: Theme.of(context).colorScheme.secondary,
          size: 150,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          child: Text(
            'YOUR STORY TEXT',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Form(
                  key: textFormKey,
                  child: TextFormField(
                    controller: textController,
                    focusNode: textFocusNode,
                    maxLength: 200,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter your story text...',
                      contentPadding: EdgeInsets.only(left: 5),
                    ),
                    validator: (value) {
                      if (value == null || value == '') {
                        return 'Story text cannot be empty.';
                      }
                      return null;
                    },
                    onTapOutside: (event) {
                      textFocusNode.unfocus();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        IconButton(
          onPressed: () async {
            if (textFormKey.currentState!.validate()) {
              try {
                setState(() {
                  isLoading = true;
                });
                StoryPhoto storyPhoto = StoryPhoto(
                  userId: UserCredential.userProfile.id,
                  photoUrl: textController.text,
                  timestamp: DateTime.now().toString(),
                  likedIds: '',
                );
                await API().addStoryPhoto(storyPhoto);
                if (mounted) {
                  Navigator.pop(context);
                }
              } on Exception catch (e) {
                setState(() {
                  isLoading = false;
                });
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: DesignProvider.getDialogBoxShape(10),
                      title: const Text('Error'),
                      content: const Text('Error occour, try again.'),
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
          },
          icon: Icon(
            EneftyIcons.direct_send_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        ),
      ],
    );
  }
}
