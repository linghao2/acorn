import 'package:flutter/material.dart';
import 'cover_flow.dart';
import 'flash_card.dart';
import 'card-definition.dart';

class TestView extends StatelessWidget {
  TestView({ this.words });

  final List words;
  var cards = List();
  CoverFlow coverFlow;

  @override
  Widget build(BuildContext context) {
    _buildContainers();

    coverFlow = new CoverFlow(
      itemBuilder: cardBuilder,
      itemCount: words.length,
      dismissibleItems: false,
    );

    return coverFlow;
  }

  Widget cardBuilder(BuildContext context, int index) {
    return cards[index];
  }

  void _buildContainers() {
    for (int i = 0; i < words.length; i++) {
      var word = words[i];
      var card = new FlashCard(
        word: word,
        count: i+1,
        totalCount: words.length,
        showFront: true,
        onNext: (FeedbackScore score) {
          print('$score');
          coverFlow.nextPage();
        },
      );
      cards.add(card);
    }
  }

}