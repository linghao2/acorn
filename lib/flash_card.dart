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

class FlashCardState extends State<FlashCard> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _frontScale;
  Animation<double> _backScale;

  void _toggleShowFront() {
    setState(() {
      widget.showFront = !widget.showFront;
      if (widget.showFront) {
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

//    _controller = AnimationController(
//        duration: const Duration(milliseconds: 500), vsync: this)
//      ..addStatusListener((status) {
//        if (status == AnimationStatus.completed) {
//          print('animation completed');
//          //_controller.reverse();
//        }
//        if (status == AnimationStatus.dismissed) {
//          print('animation dismissed');
//          //Navigator.pop(context);
//        }
//      });

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

//    print('show $widget.showFront');
//    if (widget.showFront) {
//      return frontCard;
//    } else {
//      return backCard;
//    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return Stack(
          children: <Widget>[
            new Transform(transform: Matrix4.identity()..scale(_frontScale.value, 1.0, 1.0),
              alignment: FractionalOffset.center,
              child: frontCard,
            ),
            new Transform(transform: Matrix4.identity()..scale(_backScale.value, 1.0, 1.0),
              alignment: FractionalOffset.center,
              child: backCard,
            )
          ],
        );
      },
    );
  }

}