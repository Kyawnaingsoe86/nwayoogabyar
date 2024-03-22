import 'package:flutter/material.dart';
import 'package:nwayoogabyar/data/fortune.dart';
import 'package:nwayoogabyar/view/fortunewheel.dart';

class FortuneQuestionPage extends StatefulWidget {
  const FortuneQuestionPage({super.key});

  @override
  State<FortuneQuestionPage> createState() => _FortuneQuestionPageState();
}

class _FortuneQuestionPageState extends State<FortuneQuestionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Select question'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: FortuneQnA.questions.length,
          itemBuilder: (contex, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => FortuneWheelPage(
                      question: FortuneQnA.questions[index].toString(),
                      questionNumber: index,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.background,
                    ],
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  FortuneQnA.questions[index],
                  style: const TextStyle(height: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
