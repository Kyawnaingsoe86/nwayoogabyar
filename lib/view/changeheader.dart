import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';

class ChangeHeader extends StatefulWidget {
  final String headerImg;
  const ChangeHeader({
    super.key,
    required this.headerImg,
  });

  @override
  State<ChangeHeader> createState() => _ChangeHeaderState();
}

class _ChangeHeaderState extends State<ChangeHeader> {
  int selectedIndex = 0;
  String selectedHeader = '';
  bool isLoading = false;
  @override
  void initState() {
    selectedHeader = widget.headerImg;
    for (int i = 0; i < UserCredential.headerImages.length; i++) {
      if (UserCredential.headerImages[i] == widget.headerImg) {
        selectedIndex = i;
        break;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Header'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: UserCredential.headerImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          selectedHeader = UserCredential.headerImages[index];
                        });
                      },
                      child: Container(
                        height: 120,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow,
                              blurRadius: 2,
                              spreadRadius: 0,
                              offset: const Offset(1, 1),
                            )
                          ],
                          borderRadius: BorderRadius.circular(10),
                          border: selectedIndex == index
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 5,
                                )
                              : null,
                          image: DecorationImage(
                            image: AssetImage(
                              UserCredential.headerImages[index],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
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
                      await UserCredential.changeHeaderImage(selectedHeader);
                      if (mounted) {
                        Navigator.pop(context, selectedHeader);
                      }
                    } on Exception catch (e) {
                      print(e);
                      UserCredential.userProfile.headerImg = widget.headerImg;
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
                          borderRadius: BorderRadius.circular(5))),
                  child: const Text("Change"),
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
                      Text('Please wait...')
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
