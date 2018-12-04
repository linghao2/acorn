import 'dart:convert';
import 'material_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle ;

import 'settings.dart';
import 'test_view.dart';
import 'word_data.dart';
import 'word_list.dart';

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
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => MyHomePage(title: 'Acorn'),
      },
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

  List<String> _dictionaryValues = List<String>();

  final _formKey = new GlobalKey<FormState>();

  void initState() {
    super.initState();

    _loadDictionary();
  }

  void _performTest() async {
    List<WordInfo> testWords = await DbHelper().selectWordsToTest(4);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return TestView(wordInfos: testWords,);
        },
      ),
    );

    // record feedback
    for (WordInfo info in testWords) {
      info.recordFeedback();
    }
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
                color: Color(0xFFFFFAE2),
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
            ListTile(
              title: Text('Debug'),
              leading: Icon(
                Icons.bug_report,
                color: Color(0xFFFFB20A),
              ),
              onTap: () {
                DbHelper().dumpTables();
              },
            ),
          ]
        ),
      ),
      appBar: new AppBar(
        elevation: 0.0,
        actions: <Widget> [
          IconButton(
            icon: Image.asset('graphics/cardsIcon.png'),
            onPressed: _performTest,
          ),
        ],
      ),
      body: WordList(),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            _showMaterialSearch(context);
          },
          tooltip: 'Search',
          backgroundColor: Color(0xFFFFB20A),
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
                if (value is WordInfo) {
                  // TODO push definition
                  //_pushDefinition(value);
                }
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
        _addWord(value);
      });
    });
  }

  _addWord(String word) async {
    bool containsWord = await DbHelper().containsWord(word);
    if (!containsWord) {
      var wordInfo = WordInfo(
        word: word,
        score: 0,
      );

      await DbHelper().insert(wordInfo);
    }
  }

  _loadDictionary() async  {
    String value =  await rootBundle.loadString('dictionary.txt');

    _dictionaryValues = LineSplitter().convert(value);
  }

}
