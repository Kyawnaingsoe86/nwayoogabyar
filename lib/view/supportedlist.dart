import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/model/post.dart';
import 'package:nwayoogabyar/view/viewpost.dart';

class SupportedList extends StatefulWidget {
  const SupportedList({super.key});

  @override
  State<SupportedList> createState() => _SupportedListState();
}

class _SupportedListState extends State<SupportedList> {
  bool isLoading = true;
  List<Post> supportedPosts = [];

  getSupportedPosts() {
    supportedPosts = [];
    setState(() {
      isLoading = true;
    });
    supportedPosts = UserCredential.getSupportedPost();

    setState(() {
      supportedPosts;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getSupportedPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: const Text('Supported List'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
      ),
      body: isLoading
          ? Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(
                        MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? './lib/image/Loading_dark.gif'
                            : './lib/image/Loading_light.gif',
                      ),
                    ),
                  ),
                ),
              ),
            )
          : supportedPosts.isEmpty
              ? const Center(
                  child: Text('No supported posts.'),
                )
              : ListView.builder(
                  itemCount: supportedPosts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewPost(post: supportedPosts[index]),
                            ));
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                      supportedPosts[index].coverPhotoUrl,
                                    ),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    supportedPosts[index].mmTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  supportedPosts[index].author,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  supportedPosts[index].category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
