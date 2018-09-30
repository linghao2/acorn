import 'package:flutter/material.dart';
import 'word_data.dart';

class CardDefinitionView extends StatelessWidget {
  CardDefinitionView({ this.word, this.isFlashCard = false });

  final String word;
  bool isFlashCard = false;

  @override
  Widget build(BuildContext context) {
    final _bigFont = const TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0);
    return new Container(
      child: new Card(
        color: isFlashCard ? new Color(0xFFFFFAE1) : Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
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
            margin: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: FutureBuilder(
              future: WordData.fetchDefinition(word),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(snapshot.data.category,
                          style: TextStyle(color: Colors.purple)
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 8.0),
                        ),
                        Text(snapshot.data.definitions[0]),
                        Text(''),
                      ],
                    );
                    //List<String> definitions = snapshot.data.definitions;
                    //return Text(snapshot.data.category);
//                    List<Widget> children = [
//                      Text(snapshot.data.category,
//                      style: TextStyle(color: Colors.purple),),
//                    ];
//                    return Column(
//                          children: children
//                    );
//    }
                  }
                  return CircularProgressIndicator();
                }
            ),
          ),
        ],
      ),
    ),
    );
  }
}
