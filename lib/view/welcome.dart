import 'package:flutter/material.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/home.dart';

class WelcomePage extends StatefulWidget {
  final String userName;
  final String password;
  const WelcomePage({
    super.key,
    required this.userName,
    required this.password,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  createNewUser() async {
    try {
      await API().addNewUser(widget.userName, widget.password);
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (contex) => const HomePage(
                      isNewUser: true,
                    )));
      }
    } on Exception catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: DesignProvider.getDialogBoxShape(10),
            title: const Text('Error!'),
            content: const Text('Error occour!! Please Try again.'),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK')),
            ],
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    createNewUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: Image.asset(
                    './lib/image/Logo.png',
                    width: 80,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Wait, your account is creating...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.shadow,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'NWAY OO GABYAR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'Version: ${UserCredential.version}+${UserCredential.buildNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.shadow,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }
}
