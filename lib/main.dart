import 'card-definition.dart';
import 'dart:convert';
import 'material_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'settings.dart';
import 'test_view.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Acorn',
      theme: new ThemeData(
        //buttonColor: new Color(0xFFFFF2B6),
        primaryColor: new Color(0xFFFFF2B6),
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

  List<String>_words = ['anthelion', 'anthropology', 'company', 'is'];
  List<String> _dictionaryValues = List<String>();

  final _formKey = new GlobalKey<FormState>();
  Widget _buildList() {
    _loadDictionary();
    return ListView.builder(
        padding: const EdgeInsets.all(0.0),
        itemCount: _words.length,
        itemBuilder: (context, i) {
          return _buildRow(_words[i]);
        });
  }

  Widget _buildRow(String word) {
    return ListTile(
      title: Text(
        word,
      ),
      trailing: new Icon(
        Icons.linear_scale,
        color: new Color(0xFFFFB20A),
      ),
      onTap: () {
        _pushDefinition(word);
      },
    );
  }

  void _pushDefinition(String word) {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            appBar: new AppBar(
              title: Text(word),
            ),
            body: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: new Row(
                    children: [
                      Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: new CardDefinitionView(word: word),
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

  void _performTest() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
              appBar: new AppBar(
                title: Text('Test'),
              ),
              body: new Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: new Row(
                      children: [
                        Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              child: new TestView(words: _words),
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
                  icon: const Icon(Icons.settings),
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
      appBar: new AppBar(
        title: new Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.dashboard),
          onPressed: _performTest,
        ),
        actions: <Widget> [
          new IconButton(icon: const Icon(Icons.settings), onPressed: _settings,)
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
        if (!_words.contains(value)) {
          _words.add(value);
        }
      });
    });
  }

  _loadDictionary() async  {
    String value =  await rootBundle.loadString('dictionary.txt');

    _dictionaryValues = LineSplitter().convert(value);
  }

}
