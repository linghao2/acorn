import 'package:flutter/material.dart';
import 'package:simple_coverflow/simple_coverflow.dart';
import 'flash_card.dart';

class TestView extends StatelessWidget {
  TestView({ this.words });

  final List words;
  var cards = List();

  @override
  Widget build(BuildContext context) {
    _buildContainers();

    return new CoverFlow(
      itemBuilder: cardBuilder,
      itemCount: words.length,
      dismissibleItems: false,
    );
  }

  Widget cardBuilder(BuildContext context, int index) {
    return cards[index];
  }

  void _buildContainers() {
    for (int i = 0; i < words.length; i++) {
      var word = words[i];
      var card = new FlashCard(word: word, showFront: true,);
      cards.add(card);
    }
  }

}