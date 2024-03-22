import 'dart:io';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nwayoogabyar/controller/api.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/design_provider.dart';
import 'package:nwayoogabyar/view/aboutus.dart';
import 'package:nwayoogabyar/view/home.dart';
import 'package:nwayoogabyar/view/loading.dart';
import 'package:nwayoogabyar/view/register.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController userId = TextEditingController();
  TextEditingController password = TextEditingController();
  bool loading = false;
  bool preCheck = false;
  bool hidePassword = true;
  bool isConnectionError = false;

  getUserById(String id) async {
    setState(() {
      loading = true;
    });
    try {
      await API().getUserById(id);
      setState(() {
        loading = false;
      });
    } on Exception catch (e) {
      setState(() {
        loading = false;
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: DesignProvider.getDialogBoxShape(10),
            title: const Text('Connection Error'),
            content: const Text('Connection Error. Please try again.'),
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

  bool checkUserId(String inputUserId) {
    bool result = false;
    if (!UserCredential.isNew && UserCredential.userProfile.id == inputUserId) {
      result = true;
    } else {
      result = false;
    }
    return result;
  }

  checkPassword(String inputPassword) {
    if (UserCredential.isNew) {
      return false;
    } else if (UserCredential.userProfile.password == inputPassword) {
      return true;
    }
    return false;
  }

  Future<bool> onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: DesignProvider.getDialogBoxShape(10),
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => onWillPop(),
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Image.asset(
                      './lib/image/Logo.png',
                      width: 80,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: TextFormField(
                        controller: userId,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: const InputDecoration(
                          prefix: Text('NOG'),
                          hintText: 'Please enter 5-digit code.',
                        ),
                        validator: (value) {
                          if (value == null || value == '') {
                            return 'Please enter User Id.';
                          } else if (!preCheck &&
                              !checkUserId('NOG${userId.text}')) {
                            return "User Id doesn't exist.";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: TextFormField(
                        controller: password,
                        obscureText: hidePassword,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          hintText: 'Please enter password.',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                              icon: Icon(hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility)),
                        ),
                        validator: (value) {
                          if (value == null || value == '') {
                            return 'Please enter password';
                          } else if (UserCredential.isNew) {
                            return "User Id doesn't exist.";
                          } else if (!preCheck &&
                              !checkPassword(password.text)) {
                            return "Wrong password. Please try again.";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ))),
                        onPressed: () async {
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          if (userId.text.isEmpty || password.text.isEmpty) {
                            preCheck = true;
                            formKey.currentState!.validate();
                            return;
                          } else {
                            preCheck = false;
                          }
                          await getUserById('NOG${userId.text}');
                          if (formKey.currentState!.validate()) {
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(
                                    isNewUser: false,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const Text('Log in'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                          text: "If you don't have account, please register ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                                text: 'here.',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Register()));
                                  }),
                          ]),
                    ),
                    const SizedBox(height: 50),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'You can see our\n',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          height: 2,
                        ),
                        children: [
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).colorScheme.secondary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const InfoPage(
                                          title: 'Privacy Policy',
                                          infoKey: 'privacy_policy'),
                                    ));
                              },
                          ),
                          TextSpan(
                            text: ' & ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                              text: 'Terms and Condition',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const InfoPage(
                                            title: 'Terms and Conditions',
                                            infoKey: 'terms_conditions'),
                                      ));
                                }),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Get Help: '),
                        IconButton(
                          onPressed: () {
                            launchUrlString(
                              'https://m.me/OurSoulFutureMM',
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.facebookMessenger,
                            color: Color(0xFF00B2FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            loading
                ? const LoadingPage(
                    title: 'Log in',
                    icon: EneftyIcons.profile_circle_outline,
                    info: 'Wait....')
                : Container(),
          ],
        ),
      ),
    );
  }
}
