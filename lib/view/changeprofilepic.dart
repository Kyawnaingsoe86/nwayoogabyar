import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/uploadprofilepic.dart';

class ChangeProfilePicture extends StatefulWidget {
  const ChangeProfilePicture({super.key});

  @override
  State<ChangeProfilePicture> createState() => _ChangeProfilePictureState();
}

class _ChangeProfilePictureState extends State<ChangeProfilePicture> {
  int selectedIndex = 0;
  bool isLoading = false;
  String oldAvatar = UserCredential.userProfile.userAvatar;
  int length = 0;

  @override
  void initState() {
    length = UserCredential.avatars.length;
    if (UserCredential.userProfile.userAvatar.startsWith('http') &&
        UserCredential.avatars.last != UserCredential.userProfile.userAvatar) {
      UserCredential.avatars.last = UserCredential.userProfile.userAvatar;
      setState(() {
        UserCredential.avatars;
      });
    }
    selectedIndex =
        UserCredential.avatars.indexOf(UserCredential.userProfile.userAvatar);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 1,
        elevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
        title: const Text('Change Avatar'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: length,
                  itemBuilder: (context, index) {
                    return index == length - 1
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UploadProfilePage(oldAvatar: oldAvatar),
                                ),
                              ).then((value) {
                                setState(() {
                                  UserCredential.avatars;
                                  selectedIndex = index;
                                });
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                        UserCredential.avatars[index])),
                                border: selectedIndex == index
                                    ? Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 5)
                                    : Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline),
                              ),
                              child: Container(
                                width: double.infinity,
                                color: Theme.of(context).colorScheme.shadow,
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  'Upload Pic',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  border: selectedIndex == index
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 5)
                                      : Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          UserCredential.avatars[index]))),
                            ),
                          );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      await UserCredential.changeUserAvatar(
                          UserCredential.avatars[selectedIndex]);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } on Exception catch (e) {
                      UserCredential.userProfile.userAvatar = oldAvatar;
                      UserCredential.editBlogProfileAvatar(
                          UserCredential.userProfile.id, oldAvatar);
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: DesignProvider.getDialogBoxShape(10),
                            title: const Text('Error'),
                            content:
                                const Text('Error occour. Please try later.'),
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
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text('Change'),
                ),
              ),
            ],
          ),
          isLoading
              ? Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.shadow,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text(
                        'Please wait!!',
                        style: TextStyle(
                          color: Colors.white,
                        ),
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
