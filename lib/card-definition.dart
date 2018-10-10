import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'word_data.dart';

class CardDefinitionView extends StatelessWidget {
  CardDefinitionView({ this.word, this.isFlashCard = false });

  final String word;
  bool isFlashCard = false;

  List<Widget> _buildFlashCardDefinitions(List definitions) {
    List<Widget> children = new List<Widget>();
    for (int i = 0; i < definitions.length; i++) {
      children.add(Row(
        children: <Widget>[
          Text(
            '•',
          ),
          Container(
            padding: EdgeInsets.only(right: 8.0),
          ),
          Expanded(
            child: Text(
              definitions[i],
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      )
      );
      children.add(Container(
        padding: EdgeInsets.only(bottom: 8.0),
      ));
    }
    return children;
  }

  void playUrl(String url) async {
    AudioPlayer.logEnabled = true;
    AudioPlayer audioPlayer = new AudioPlayer();
    int result = await audioPlayer.play(url);
    if (result == 1) {
      await audioPlayer.setReleaseMode(ReleaseMode.STOP);
    }
  }

  Widget buildPronounciation(LexicalDefinition definition) {
    if (definition.pronunciationSpelling != null) {
      var widget = Row(
        children: <Widget>[
          Text(
            '[' + definition.pronunciationSpelling + ']',
            style: TextStyle(color: Colors.black45),
          ),
          IconButton(
            icon: Icon(
              Icons.speaker_phone,
              color: definition.pronunciationUrl != null ? Colors.black : Colors.black26,
            ),
            onPressed: () {
              playUrl(definition.pronunciationUrl);
            },
          ),
          Container(
            padding: EdgeInsets.only(bottom: 0.0),
          ),
        ],
      );
      return widget;
    }
    return null;
  }

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
            margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
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
                    WordDefinition wordDefinition = snapshot.data;
                    List<Widget> children = new List<Widget>();

                    for (LexicalDefinition definition in wordDefinition.entries) {
                      // pronunciation
                      var pronounciationWidget = buildPronounciation(definition);
                      if (pronounciationWidget != null) {
                        children.add(pronounciationWidget);
                      }

                      // category
                      if (definition.category != null) {
                        children.add(new Text(
                            definition.category,
                            style: TextStyle(color: Colors.purple)
                        ));
                        children.add(Container(
                          padding: EdgeInsets.only(bottom: 8.0),
                        ));
                      }

                      children.addAll(_buildFlashCardDefinitions(definition.definitions));
                    }

                    return Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    );
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
