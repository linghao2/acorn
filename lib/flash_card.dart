import 'package:flutter/material.dart';
import 'card-definition.dart';
import 'word_data.dart';

class FlashCard extends StatefulWidget {
  FlashCard({ this.wordInfo, this.showFront = true, this.count = 0, this.totalCount = 0, this.onNext });

  final _bigFont = const TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0);

  final WordInfo wordInfo;
  final bool showFront;
  final OnNext onNext;
  final int count;
  final int totalCount;

  @override
  State<StatefulWidget> createState() => new FlashCardState();
}

class FlashCardState extends State<FlashCard> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _frontScale;
  Animation<double> _backScale;

  bool _showFront;

  void _toggleShowFront() {
    setState(() {
      _showFront = !_showFront;
      if (_showFront) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _frontScale = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: new Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _backScale = new CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _showFront = widget.showFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        color: Color(0xFFFFF2B6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Center(
              child: Text(
                widget.wordInfo.word,
                style: widget._bigFont,
              )   ,
            ),
          ],
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
      child: CardDefinitionView(
          wordInfo: widget.wordInfo,
          isFlashCard: true,
          onNext: (FeedbackScore score) => widget.onNext(score),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return Stack(
          children: <Widget>[
            Transform(transform: Matrix4.identity()..scale(_frontScale.value, 1.0, 1.0),
              alignment: FractionalOffset.center,
              child: frontCard,
            ),
            Transform(transform: Matrix4.identity()..scale(_backScale.value, 1.0, 1.0),
              alignment: FractionalOffset.center,
              child: backCard,
            )
          ],
        );
      },
    );
  }

}