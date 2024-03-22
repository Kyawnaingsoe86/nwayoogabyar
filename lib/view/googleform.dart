import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MyGoogleForm extends StatefulWidget {
  const MyGoogleForm({super.key});

  @override
  State<MyGoogleForm> createState() => _MyGoogleFormState();
}

class _MyGoogleFormState extends State<MyGoogleForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _fileController = TextEditingController();
  FocusNode titleFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  FocusNode attachFocusNode = FocusNode();
  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send File"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: TextFormField(
                      controller: _titleController,
                      focusNode: titleFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Title:',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: const EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                      ),
                      onTapOutside: (event) => titleFocusNode.unfocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title.';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: TextFormField(
                      controller: _descriptionController,
                      focusNode: descriptionFocusNode,
                      maxLines: 6,
                      maxLength: 5000,
                      decoration: InputDecoration(
                        labelText: 'Description:',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: const EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                      ),
                      onTapOutside: (event) => descriptionFocusNode.unfocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description.';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: TextFormField(
                      controller: _fileController,
                      focusNode: attachFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Attach File Link:',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: const EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        suffix: GestureDetector(
                          onTap: () {
                            attachFocusNode.unfocus();
                            launchUrlString(
                              'https://files.fm/',
                              mode: LaunchMode.inAppBrowserView,
                            );
                          },
                          child: Icon(
                            EneftyIcons.document_upload_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      onTapOutside: (event) => attachFocusNode.unfocus(),
                    ),
                  ),
                  ElevatedButton(
                    style: DesignProvider.getElevationButtonShape(
                      5,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.onSecondary,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isSending = true;
                        });
                        try {
                          String title = _titleController.text;
                          String description = _descriptionController.text;
                          String fileUrl = _fileController.text;
                          await API().sendFile(title, description, fileUrl);
                          if (mounted) {
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: DesignProvider.getDialogBoxShape(10),
                                title: const Text("Sent!"),
                                content: const Text(
                                    "File has been sent successfully!"),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        } on Exception catch (e) {
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Fail!"),
                                content: const Text(
                                    "Error occour!! Please try again later."),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
          isSending
              ? Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.shadow,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        EneftyIcons.document_upload_outline,
                        size: 100,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(),
                          ),
                          SizedBox(width: 10),
                          Text("Sending...."),
                        ],
                      )
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
