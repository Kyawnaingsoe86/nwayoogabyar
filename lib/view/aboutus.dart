import 'dart:async';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatefulWidget {
  final String title;
  final String infoKey;
  const InfoPage({
    super.key,
    required this.title,
    required this.infoKey,
  });

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  bool isLoading = false;
  String content = '';
  Timer? reloadTimer;

  loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      content = await API().getInfo(widget.infoKey);

      setState(() {
        content;
        isLoading = false;
      });
    } on Exception catch (e) {
      reloadTimer?.cancel();
      reloadTimer = Timer(const Duration(seconds: 10), () {
        loadData();
      });
    }
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  void dispose() {
    reloadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: Text(widget.title),
        titleSpacing: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(EneftyIcons.arrow_left_3_outline),
        ),
      ),
      body: isLoading
          ? LoadingPage(
              title: widget.title,
              icon: EneftyIcons.cloud_connection_outline,
              info: "Loading...")
          : SingleChildScrollView(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Linkify(
                  onOpen: (link) async {
                    if (!await launchUrl(Uri.parse(link.url),
                        mode: LaunchMode.inAppBrowserView)) {
                      throw Exception('Could not launch ${link.url}');
                    }
                  },
                  text: content,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
    );
  }
}
