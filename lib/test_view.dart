import 'package:flutter/material.dart';
import 'cover_flow.dart';
import 'flash_card.dart';
import 'word_data.dart';
import 'test_results.dart';

class _TestWidget extends StatelessWidget {
  _TestWidget({ this.wordInfos });

  final List<WordInfo> wordInfos;
  var cards = List();
  CoverFlow coverFlow;

  @override
  Widget build(BuildContext context) {
    _buildContainers(context);

    coverFlow = CoverFlow(
      itemBuilder: cardBuilder,
      itemCount: wordInfos.length,
      dismissibleItems: false,
    );
    return coverFlow;
  }

  Widget cardBuilder(BuildContext context, int index) {
    return cards[index];
  }

  void _buildContainers(BuildContext context) {
    for (int i = 0; i < wordInfos.length; i++) {
      var card = new FlashCard(
        wordInfo: wordInfos[i],
        count: i+1,
        totalCount: wordInfos.length,
        showFront: true,
        onNext: (FeedbackScore score) {
          wordInfos[i].scoreFeedback(score);
          if (i == wordInfos.length-1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => TestResults(wordInfos: wordInfos,)));
          } else {
            coverFlow.nextPage();
          }
        },
      );
      cards.add(card);
    }
  }
}

class TestView extends StatelessWidget {
  TestView({ this.wordInfos });
  final List<WordInfo> wordInfos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: Text('Acorn Test'),
          elevation: 0.0,
        ),
        body: new Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: new Row(
                children: [
                  Expanded(
                      child: Container(
                        child: _TestWidget(wordInfos: wordInfos,),
                      )
                  ),
                ],
              ),
            ),
            new Container(
              padding: EdgeInsets.only(bottom: 32.0),
            ),
          ],
        )
    );
  }
}