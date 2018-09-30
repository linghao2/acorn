import 'package:flutter/material.dart';
import 'card-definition.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'material_search.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Acorn',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
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
  List<String> _words = ['anthelion', 'anthropology'];
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
        color: Colors.lightBlue,
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
            body: new Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new CardDefinitionView(word: word),
                  )
                ),
              ],
            ),
          );
        },
      ),
    );

  }

  void _performTest() {
    // TODO open test
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: <Widget> [
          new IconButton(icon: const Icon(Icons.dashboard), onPressed: _performTest,)
        ],
      ),
      body: _buildList(),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            _showMaterialSearch(context);
          },
          tooltip: 'Search',
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
