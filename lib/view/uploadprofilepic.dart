import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadProfilePage extends StatefulWidget {
  final String oldAvatar;
  const UploadProfilePage({
    super.key,
    required this.oldAvatar,
  });

  @override
  State<UploadProfilePage> createState() => _UploadProfilePageState();
}

class _UploadProfilePageState extends State<UploadProfilePage> {
  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(EneftyIcons.arrow_left_3_outline)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  child: Icon(
                    EneftyIcons.document_upload_outline,
                    size: 150,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Form(
                  key: formKey,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter photo url.',
                        errorMaxLines: 2,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            width: 1,
                          ),
                        ),
                        suffix: GestureDetector(
                          onTap: () {
                            focusNode.unfocus();
                            launchUrl(
                              Uri.parse('https://postimages.org/'),
                              mode: LaunchMode.inAppBrowserView,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: Icon(EneftyIcons.gallery_export_outline),
                          ),
                        ),
                      ),
                      onTapOutside: (event) {
                        focusNode.unfocus();
                      },
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
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          setState(() {
                            isLoading = true;
                          });
                          await UserCredential.changeUserAvatar(
                              controller.text);
                          UserCredential.avatars.removeLast();
                          UserCredential.avatars.add(controller.text);
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } on Exception catch (e) {
                          print(e);
                          UserCredential.userProfile.userAvatar =
                              widget.oldAvatar;
                          UserCredential.editBlogProfileAvatar(
                              UserCredential.userProfile.id, widget.oldAvatar);
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: DesignProvider.getDialogBoxShape(10),
                                title: const Text('Error'),
                                content: const Text(
                                    'Error occour. Please try later.'),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: DesignProvider.getElevationButtonShape(
                      5,
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    child: const Text('UPLOAD'),
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? const LoadingPage(
                  title: 'Uploading',
                  icon: EneftyIcons.document_upload_outline,
                  info: 'Uploading Profile Photo...',
                )
              : Container(),
        ],
      ),
    );
  }
}
