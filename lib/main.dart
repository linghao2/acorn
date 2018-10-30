import 'dart:convert';
import 'material_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'settings.dart';
import 'test_view.dart';
import 'card-definition.dart';
import 'word_data.dart';

const darkYellowColor = Color(0xFFB20A);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Acorn',
      theme: new ThemeData(
        //buttonColor: new Color(0xFFFFF2B6),
        primaryColor: Color(0xFFF4F4F4),
        canvasColor: Color(0xFFF4F4F4),
      ),
      home: new MyHomePage(title: 'Acorn'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<WordInfo> _wordInfos = List<WordInfo>();
  List<String> _dictionaryValues = List<String>();

  final _formKey = new GlobalKey<FormState>();

  void initState() {
    super.initState();

    _loadWords();
    _loadDictionary();
  }

  Widget _buildList() {
    var listView = ListView.builder(
        itemCount: _wordInfos.length,
        itemBuilder: (context, i) {
          return _buildRow(_wordInfos[i]);
        });
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F4),
      ),
      child: listView,
    );

  }

  Widget _buildRow(WordInfo wordInfo) {
    print(wordInfo.score);
    var word = wordInfo.word;
    var score = wordInfo.score;

    var listTile = ListTile(
      title: Text(
        wordInfo.word,
      ),
      trailing: Image.asset('graphics/${score}.png'),
      onTap: () {
        _pushDefinition(wordInfo);
      },
    );

    return Dismissible(
      key: new Key(word),
      onDismissed: (direction) {
        _wordInfos.remove(wordInfo);
      },
      child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
          child: new Card(
            elevation: 0.0,
            child: listTile,
          ),
      ),
    );
  }

  void _pushDefinition(WordInfo wordInfo) {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            appBar: new AppBar(
//              iconTheme: IconThemeData(
//                color: Colors.purple, //change your color here
//              ),
              elevation: 0.0,
            ),
            body: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: new Row(
                    children: [
                      Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                            child: new CardDefinitionView(wordInfo: wordInfo),
                          )
                      ),
                    ],
                  ),
                ),
                new Container(
                  padding: EdgeInsets.only(bottom: 16.0),
                ),
              ],
            )
          );
        },
      ),
    );

  }

  void _performTest() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
              appBar: new AppBar(
                title: Text('Test'),
                elevation: 0.0,
              ),
              body: new Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: new Row(
                      children: [
                        Expanded(
                            child: Container(
                              child: new TestView(wordInfos: _wordInfos,),
                            )
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.only(bottom: 32.0),
                  ),
                ],
              )
          );
        },
      ),
    );
  }

  void _settings() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            appBar: new AppBar(
              title: Text('Settings'),
              leading: IconButton(
                  icon: const Icon(Icons.settings,
                    color: Color(0xFFFFB20A)),
                  onPressed: null),
              actions: <Widget> [
                new IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: (){
                      Navigator.maybePop(context);
                    }
                ),
              ],
            ),

            body: new Row(
              children: [
                Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18.0),
                      child: new SettingsView(),
                    )
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF57E191),
              ),
              child: Column(
                children: <Widget>[
                  Image.asset('graphics/acorn.png'),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Learn words more efficiently with Acorn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),

                  ),
                ],
              )
            ),
            ListTile(
              title: Text('Settings'),
              leading: Icon(
                Icons.settings,
                color: Color(0xFFFFB20A),
              ),
              onTap: () {
                Navigator.pop(context);
                _settings();
              },
            ),
          ]
        ),
      ),
      appBar: new AppBar(
        elevation: 0.0,
        actions: <Widget> [
          //new IconButton(icon: const Icon(Icons.settings), onPressed: _settings,)
          IconButton(
            icon: Image.asset('graphics/cardsIcon.png'),
            onPressed: _performTest,
          ),
        ],
      ),
      body: _buildList(),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            _showMaterialSearch(context);
          },
          tooltip: 'Search',
          backgroundColor: new Color(0xFFFFB20A),
          child: new Icon(Icons.search),
        )
    );
  }


  _buildMaterialSearchPage(BuildContext context) {

    return new MaterialPageRoute<String>(
        settings: new RouteSettings(
          name: 'material_search',
          isInitialRoute: false,
        ),
        builder: (BuildContext context) {
          return new Material(
            child: new MaterialSearch<String>(
              placeholder: 'Lookup your word',

              results: _dictionaryValues.map((String v) => new MaterialSearchResult<String>(
                icon: Icons.add,
                value: v,
                text: "$v",
                  onSubmit: (String value) => Navigator.of(context).pop(value)
              )).toList(),
              filter: (dynamic value, String criteria) {
                return value.toLowerCase().trim()
                    .startsWith(new RegExp(r'' + criteria.toLowerCase().trim() + ''));
              },
              limit: 20,
             // onSelect: (dynamic value) => Navigator.of(context).pop(value),
              onSelect: (dynamic value) {
                _pushDefinition(value);
              },
              onSubmit: (String value) => Navigator.of(context).pop(value),
            ),
          );
        }
    );
  }

  _showMaterialSearch(BuildContext context) {
    Navigator.of(context)
        .push(_buildMaterialSearchPage(context))
        .then((dynamic value) {
      setState(() {
        if (!_containsWord(value)) {
          _wordInfos.add(WordInfo(
            word: value,
            score: 0,
          ));
        }
      });
    });
  }

  bool _containsWord(String word) {
    for (WordInfo wordInfo in _wordInfos) {
      if (wordInfo.word == word) {
        return true;
      }
    }
    return false;
  }

  _loadWords() async {
    _wordInfos.add(WordInfo(
      word: 'anthelion',
      score: 1,
    ));
    _wordInfos.add(WordInfo(
      word: 'anthropology',
      score: 2,
    ));
    _wordInfos.add(WordInfo(
      word: 'long',
      score: 3,
    ));
    _wordInfos.add(WordInfo(
      word: 'short',
      score: 4,
    ));
  }

  _loadDictionary() async  {
    String value =  await rootBundle.loadString('dictionary.txt');

    _dictionaryValues = LineSplitter().convert(value);
  }

}
