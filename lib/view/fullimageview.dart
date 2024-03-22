import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';

class FullImageView extends StatelessWidget {
  final String imgUrl;
  const FullImageView({
    super.key,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Image.network(imgUrl),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                EneftyIcons.close_circle_outline,
                size: 50,
              ),
            )
          ],
        ),
      ),
    );
  }
}
