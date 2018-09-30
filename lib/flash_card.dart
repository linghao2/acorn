import 'package:flutter/material.dart';
import 'card-definition.dart';

class FlashCard extends StatefulWidget {
  FlashCard({ this.word, this.showFront });

  final _bigFont = const TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0);

  var word = 'word';
  var showFront = true;

  @override
  State<StatefulWidget> createState() => new FlashCardState();

}

class FlashCardState extends State<FlashCard> {

  void _toggleShowFront() {
    setState(() {
      widget.showFront = !widget.showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    var frontCard = new GestureDetector(
      onTap: ()
      {
        print('word was tapped $widget.word');
        _toggleShowFront();
      },
      child: new Card(
        color: new Color(0xFFFFF2B6),
        child: new Center(
          child: Text(
            widget.word,
            style: widget._bigFont,
          )   ,
        ),
      ),
      /*
      */
    );

    var backCard = new GestureDetector(
      onTap: ()
      {
        print('definition was tapped $widget.word');
        _toggleShowFront();
      },
      child: new CardDefinitionView(word: widget.word, isFlashCard: true),
    );

    print('show $widget.showFront');
    if (widget.showFront) {
      return frontCard;
    } else {
      return backCard;
    }
  }

}