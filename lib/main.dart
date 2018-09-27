import 'package:flutter/material.dart';
import 'card-definition.dart';

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
  final _words = ['anthelion', 'anthropology'];

  Widget _buildList() {
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
                    child: new CardDefinitionView(word: word, definition: "definition"),
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
    );
  }
}
