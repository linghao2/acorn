import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_definition.dart';
import 'word_data.dart';
import 'globals.dart';

class WordList extends StatefulWidget {
  WordList();

  @override
  State<StatefulWidget> createState() => new WordListState();
}

class WordListState extends State<WordList>  {
  List<WordInfo> _wordInfos;
  OrderBy _orderBy;

  @override
  void initState() {
    super.initState();
  }

  void _sortList(OrderBy orderBy) {
    setState(() {
      _orderBy = orderBy;
      storeOrderBy(orderBy);
    });
  }

  Future<List<WordInfo>> getWordInfos(OrderBy orderBy) async {
    if (orderBy == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int orderByIndex = prefs.getInt('OrderBy') ?? 0;
      _orderBy = OrderBy.values[orderByIndex];
    }

    return DbHelper().getWordInfos(_orderBy);
  }

  storeOrderBy(OrderBy orderBy) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('storeOrderBy!!!!!!  ${orderBy.index}');
    prefs.setInt('OrderBy', orderBy.index);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: getWordInfos(_orderBy),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _wordInfos = snapshot.data;
          if (_wordInfos.length == 0) {
            return _buildLaunchScreen();
          } else {
            var listView = ListView.builder(
                itemCount: _wordInfos.length,
                itemBuilder: (context, i) {
                  return _buildRow(_wordInfos[i]);
                });
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _buildSortRow(),
                Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF4F4F4),
                      ),
                      child: listView,
                    )
                ),
              ],
            );
          }
        } else {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildSortRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FlatButton(
          child: Text(
            'A - Z',
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          textColor: _orderBy == OrderBy.AtoZ ? Colors.black : Colors.grey,
          color: _orderBy == OrderBy.AtoZ ? Globals.backgroundYellow : Globals.background,
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
          onPressed: () {
            _sortList(OrderBy.AtoZ);
          },
        ),
        FlatButton(
          child: Text(
            'Newest',
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          textColor: _orderBy == OrderBy.Date ? Colors.black : Colors.grey,
          color: _orderBy == OrderBy.Date ? Globals.backgroundYellow : Globals.background,
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
          onPressed: () {
            _sortList(OrderBy.Date);
          },
        ),
        FlatButton(
          child: Text(
            'Mastery Level',
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          textColor: _orderBy == OrderBy.Score ? Colors.black : Colors.grey,
          color: _orderBy == OrderBy.Score ? Globals.backgroundYellow : Globals.background,
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
          onPressed: () {
            _sortList(OrderBy.Score);
          },
        ),
      ],
    );
  }

  Widget _buildList() {
  }

  Widget _buildLaunchScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('graphics/squirrel.png'),
          Container(
            padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0, bottom: 80.0),
            child: Text(
              'Learn words more efficiently with Acorn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(WordInfo wordInfo) {
    print('word: ${wordInfo.word} score: ${wordInfo.score}');
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
        DbHelper().remove(wordInfo);
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

}
