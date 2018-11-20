import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'word_data.dart';

typedef void OnNext(FeedbackScore score);

class CardDefinitionView extends StatelessWidget {
  CardDefinitionView({ this.wordInfo, this.isFlashCard = false, this.onNext });

  final WordInfo wordInfo;
  final bool isFlashCard;
  final OnNext onNext;

  List<Widget> _buildFlashCardDefinitions(List definitions) {
    List<Widget> children = List<Widget>();
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

  void _playUrl(String url) async {
    AudioPlayer.logEnabled = true;
    AudioPlayer audioPlayer = new AudioPlayer();
    int result = await audioPlayer.play(url);
    if (result == 1) {
      await audioPlayer.setReleaseMode(ReleaseMode.STOP);
    }
  }
  Widget _buildPronounciation(LexicalDefinition definition) {
    if (definition.pronunciationSpelling != null) {
      var widget = Row(
        children: <Widget>[
          Text(
            '[' + definition.pronunciationSpelling + ']',
            style: TextStyle(color: Colors.black45),
          ),
          IconButton(
            icon: Image.asset('graphics/audio.png'),
            onPressed: () {
              _playUrl(definition.pronunciationUrl);
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

  Widget _buildIconButton(IconData icon, Color color, String text, FeedbackScore score) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: MaterialButton(
            color: Colors.white,
            splashColor: color,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  //child: Image.asset(iconPath),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
            onPressed: () { onNext(score); },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackButtons() {
    if (!isFlashCard) {
      return Container();
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildIconButton(Icons.check, Colors.green[400], 'Got it', FeedbackScore.Yes),
          //Container(width: 8.0),
          _buildIconButton(Icons.clear, Colors.red[400], 'Don\'t know', FeedbackScore.No),
        ],
      );
    }
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
              wordInfo.word,
              style: _bigFont,
            ),
          ),
          new Expanded(
            child: FutureBuilder(
              future: WordData.fetchDefinition(wordInfo.word),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    WordDefinition wordDefinition = snapshot.data;
                    List<Widget> children = new List<Widget>();

                    for (LexicalDefinition definition in wordDefinition.entries) {
                      // pronunciation
                      var pronounciationWidget = _buildPronounciation(definition);
                      if (pronounciationWidget != null) {
                        children.add(pronounciationWidget);
                      }

                      // category
                      if (definition.category != null) {
                        children.add(Text(
                            definition.category,
                            style: TextStyle(color: Colors.purple)
                        ));
                        children.add(Container(
                          padding: EdgeInsets.only(bottom: 8.0),
                        ));
                      }

                      children.addAll(_buildFlashCardDefinitions(definition.definitions));
                    }

                    if (wordDefinition.translation != null) {
                      children.add(
                        Text(
                          wordDefinition.translation,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: children.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: EdgeInsets.only(left: 16.0, right: 16.0),
                            child: children[index],
                          );
                        }
                    );
                  }
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: _buildFeedbackButtons(),
          ),
        ],
      ),
    ),
    );
  }
}
