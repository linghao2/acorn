import 'package:flutter/material.dart';
import 'cover_flow.dart';
import 'flash_card.dart';
import 'word_data.dart';

class TestView extends StatelessWidget {
  TestView({ this.wordInfos });

  final List<WordInfo> wordInfos;
  var cards = List();
  CoverFlow coverFlow;

  @override
  Widget build(BuildContext context) {
    _buildContainers();

    coverFlow = new CoverFlow(
      itemBuilder: cardBuilder,
      itemCount: wordInfos.length,
      dismissibleItems: false,
    );

    return coverFlow;
  }

  Widget cardBuilder(BuildContext context, int index) {
    return cards[index];
  }

  void _buildContainers() {
    for (int i = 0; i < wordInfos.length; i++) {
      var card = new FlashCard(
        wordInfo: wordInfos[i],
        count: i+1,
        totalCount: wordInfos.length,
        showFront: true,
        onNext: (FeedbackScore score) {
          wordInfos[i].scoreFeedback(score);
          coverFlow.nextPage();
        },
      );
      cards.add(card);
    }
  }

}