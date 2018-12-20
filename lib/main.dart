import 'dart:convert';
import 'material_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle ;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_mixpanel/pure_mixpanel.dart';

import 'new_settings.dart';
import 'test_view.dart';
import 'word_data.dart';
import 'word_list.dart';
import 'globals.dart';

const darkYellowColor = Color(0xFFB20A);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acorn',
      theme: ThemeData(
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

  void initState() {
    super.initState();

    _loadDictionary();
  }

  void _performTest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _wordCountValue = (prefs.getInt(Globals.PreferenceTestWordCount) ?? 8);
    List<WordInfo> testWords = await DbHelper().selectWordsToTest(_wordCountValue);

    Mixpanel(token: Globals.MixPanelToken).track(
      'performTest',
      properties: {'count' : '$_wordCountValue'},
    );

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
              titleSpacing: 0.0,
              elevation: 0.0,
            ),

            body: new Row(
              children: [
                Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18.0),
                      child: SettingsPage(),
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
    return Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFFFFAE2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image.asset('graphics/acorn45.png'),
                  Center(
                    child: Text(
                      'Acorn Version 0.1',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              )
            ),
            ListTile(
              title: Text(
                  'Settings',
                style: TextStyle(
                  fontSize: 20.0,
                )
              ),
              leading: Icon(
                Icons.settings,
                color: Color(0xFFFFB20A),
              ),
              onTap: () {
                Navigator.pop(context);
                _settings();
              },
            ),
//            ListTile(
//              title: Text('Debug'),
//              leading: Icon(
//                Icons.bug_report,
//                color: Color(0xFFFFB20A),
//              ),
//              onTap: () {
//                DbHelper().dumpTables();
//              },
//            ),
          ]
        ),
      ),
      appBar: new AppBar(
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Globals.darkYellow,
        ),
        actions: <Widget> [
          IconButton(
            icon: Image.asset('graphics/cardsIcon.png'),
            onPressed: _performTest,
          ),
        ],
      ),
      body: WordList(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showMaterialSearch(context);
          },
          tooltip: 'Search',
          backgroundColor: Color(0xFFFFB20A),
          foregroundColor: Colors.black,
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
