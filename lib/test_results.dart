import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:math';
import 'word_data.dart';

class TestResults extends StatelessWidget {
  TestResults({ this.wordInfos });
  final List<WordInfo> wordInfos;

  List<String> _words = ['Great Work!', 'Good Job!', 'Awesome!' ];

  @override
  Widget build(BuildContext context) {
    var random = Random();
    var index = random.nextInt(_words.length);
    var word = _words[index];
    var yes = 0;
    var no = 0;
    for (WordInfo info in wordInfos) {
      if (info.currentFeedback == FeedbackScore.Yes) {
        yes += 1;
      } else if (info.currentFeedback == FeedbackScore.No) {
        no += 1;
      }
    }
    return Scaffold(
        appBar: new AppBar(
          title: Text('Acorn Results'),
          elevation: 0.0,
        ),
        body: new Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 32.0),
            ),
            Center(
              child: Icon(
                Icons.thumb_up,
                size: 100.0,
                color: Color(0xFFFED33D),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 16.0),
            ),
            Flexible(
              flex: 2,
              child: Text(
                word,
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircularPercentIndicator(
                    radius: 90.0,
                    lineWidth: 4.0,
                    percent: yes/wordInfos.length,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${yes}',
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.green[400],
                          ),
                        ),
                        Text(
                            'Got it',
                            style: TextStyle(
                              fontSize: 12.0,
                            )
                        ),
                      ],
                    ),
                    progressColor: Colors.green[400],
                  ),
                  CircularPercentIndicator(
                    radius: 90.0,
                    lineWidth: 4.0,
                    percent: no/wordInfos.length,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${no}',
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.red[400],
                          ),
                        ),
                        Text(
                          'Don\'t Know',
                          style: TextStyle(
                            fontSize: 12.0,
                          )
                        ),
                      ],
                    ),
                    progressColor: Colors.red[400],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 32.0),
            ),
          ],
        )
    );
  }
}