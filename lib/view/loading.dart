import 'package:flutter/material.dart';
import 'package:nwayoogabyar/theme/color_schemes.dart';
import 'package:nwayoogabyar/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String info;
  const LoadingPage({
    super.key,
    required this.title,
    required this.icon,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Provider.of<ThemeProvider>(context).themeData == darkMode
          ? Colors.black
          : Colors.white,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(width: 10),
              Text(info),
            ],
          ),
        ],
      ),
    );
  }
}
