import 'package:flutter/material.dart';

class CardDefinitionView extends StatelessWidget {
  const CardDefinitionView({ this.word, this.definition });

  final String word;
  final String definition;

  @override
  Widget build(BuildContext context) {
    final _bigFont = const TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0);
    return new Card(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.all(16.0),
            child: new Text(
              word,
              style: _bigFont,
            ),
          ),
          new Container(
            margin: const EdgeInsets.all(16.0),
            child: new Text(
              definition,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
