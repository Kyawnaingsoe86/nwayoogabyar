import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nwayoogabyar/view/aboutus.dart';
import 'package:nwayoogabyar/view/welcome.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Text(
                  'REGISTRATION',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
                  controller: userName,
                  decoration: const InputDecoration(
                    labelText: 'User Name:',
                    hintText: 'Enter user name',
                  ),
                  validator: (value) {
                    if (value == null || value == '') {
                      return 'Please enter name';
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
                    labelText: 'Password:',
                    hintText: 'Please enter password.',
                    helperText:
                        'Password must has at least 5 characters, and must contain characters and digits. Eg: abc123',
                    helperMaxLines: 2,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value == '') {
                      return 'Please enter password';
                    } else if (value.length < 5) {
                      return 'Password must has at least 5 characters.';
                    } else if (value.contains(' ')) {
                      return 'Space is not allowed.';
                    } else if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must has digits';
                    } else if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                      return 'Password must has character';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: ElevatedButton(
                  onPressed: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    if (formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (contex) => WelcomePage(
                            userName: userName.text,
                            password: password.text,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Create Account'),
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'By creating an account, you are agreeding to our\n',
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
                          }),
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
                            color: Theme.of(context).colorScheme.secondary),
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
            ],
          ),
        ),
      ),
    );
  }
}
