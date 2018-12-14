import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:synchronized/synchronized.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_mixpanel/pure_mixpanel.dart';

import 'globals.dart';


enum FeedbackScore {Unspecified, Yes, No}

enum OrderBy {AtoZ, Date, Score}

class TranslateHelper {

  static Future<String> fetchTranslation(String word, String lang) async {
    String url = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=${lang}";
    String body = '[{ \'text\' : \'$word\' }]';
    print('body: $body');
    final response = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key' : '22943ebc6e4c48f88e468d12d9169641',
        'Content-type' : 'application/json',
        // TODO random UUID
        'X-clientTraceId' : '6c84fb90-12c4-11e1-840d-7b25c5ee775a',
      },
      body: body,
    );
    print(response.body);
    try {
      const JsonDecoder decoder = const JsonDecoder();
      List decoded = decoder.convert(response.body);
      for (Map entry in decoded) {
        Map one = entry['translations'][0];
        return one['text'];
      }
    } catch (e) {
      print('parse translate error $e');
    }
    return null;
  }

}

class DbHelper {
  static final DbHelper _singleton = DbHelper._internal();

  factory DbHelper() {
    return _singleton;
  }

  DbHelper._internal();

  static Database _db;
  static String path = "acorn.db";
  static final _lock = Lock();

  void remove(WordInfo wordInfo) async {
    var db = await getDb();
    var word = wordInfo.word;
    var count = await db.rawDelete('DELETE FROM Words WHERE word = ?', [word]);
    assert(count == 1);
  }

  void insert(WordInfo wordInfo) async {
    Mixpanel(token: Globals.MixPanelToken).track(
      'insertWord',
      properties: {'word' : '${wordInfo.word}'},
    );

    var db = await getDb();
    db.insert("Words", wordInfo.toMap());
  }

  String getOrderByString(OrderBy orderBy) {
    switch (orderBy) {
      case OrderBy.AtoZ:
        return 'word';
      case OrderBy.Date:
        return 'date DESC';
      case OrderBy.Score:
        return 'score, word';
    }
  }

  Future<List<WordInfo>> getWordInfos(OrderBy orderBy) async {
    var _wordInfos = List<WordInfo>();

    var db = await getDb();
    var results = await db.query("words", columns: ["word", "score", "date"], orderBy: getOrderByString(orderBy));
    for (Map<String, dynamic> map in results) {
      _wordInfos.add(WordInfo.fromMap(map));
    }
    print('getWordInfos count: ${_wordInfos.length}');
    return _wordInfos;
  }

  Future<List<WordInfo>> selectWordsToTest(int count) async {
    var _wordInfos = List<WordInfo>();

    var db = await getDb();
    var results = await db.rawQuery('SELECT word, date, score FROM Words ORDER BY score LIMIT ?', [count]);
    for (Map<String, dynamic> map in results) {
      _wordInfos.add(WordInfo.fromMap(map));
    }
    print('getWordInfos count: ${_wordInfos.length}');
    return _wordInfos;
  }




  Future<Database> getDb() async {
    if (_db == null) {
      await _lock.synchronized(() async {
        // Check again once entering the synchronized block
        if (_db == null) {
          _db = await openDatabase(path, version: 1,
            onCreate: (Database db, int version) async {
              await db.execute("CREATE TABLE Words (word TEXT PRIMARY KEY, score INTEGER, date INTEGER, testDate INTEGER, definition TEXT)");
              await db.execute("CREATE TABLE Translations(word TEXT, lang TEXT, translated TEXT, PRIMARY KEY (word, lang))");
            },
          );
        }
      });
    }
    return _db;
  }

  Future<bool> containsWord(String word) async {
    var db = await getDb();
    List<Map> list = await db.rawQuery('SELECT word from Words WHERE word = ?', [word]);
    if (list.length == 1) {
      return true;
    }
    return false;
  }

  Future<WordDefinition> getDefinition(String word) async {
    var db = await getDb();
    List<Map> list = await db.rawQuery('SELECT definition from Words WHERE word = ?', [word]);
    var definition = null;
    if (list.length == 1) {
      definition = list[0]['definition'];
      if (definition == null) {
        String url = WordData.getUrl(word);
        final response = await http.get(url, headers: WordData.getHeaders());
        if (response.statusCode == 200) {
          definition = response.body;
          int count = await db.rawUpdate('UPDATE Words SET definition = ? WHERE word = ?', [definition, word]);
          print('sql update count: $count');
        } else {
          var code = response.statusCode;
          print('failed to find definition code: $code');
          //throw Exception('Failed to load $word: $code');
        }
      }
    }

    var wordDefinition = WordDefinition.fromJson(word, definition);
    print('definition found for ${word}');
    return wordDefinition;
  }

  Future<String> getTranslated(String word, String lang) async {
    var db = await getDb();
    List<Map> list = await db.rawQuery('SELECT translated from Translations WHERE word = ? and lang = ?', [word, lang]);
    var translated = null;
    if (list.length == 1) {
      translated = list[0]['translated'];
    } else {
      translated = await TranslateHelper.fetchTranslation(word, lang);
      var map = <String, dynamic> {
        "word" : word,
        "translated" : translated,
        "lang" : lang,
      };
      var inserted = await db.insert("Translations", map);
      print('translation inserted $inserted');
    }
    if (translated != null) {
      print('translation found for ${word}');
      return translated;
    } else {
      print('NO translation for ${word}');
      return null;
    }
  }

  void updateScore(String word, int score) async {
    var db = await getDb();
    int now = DateTime.now().millisecondsSinceEpoch;
    int count = await db.rawUpdate('UPDATE Words SET score = ?, testDate = ? WHERE word = ?', [score, now, word]);
    print('sql update score count: $count');
  }

  void dumpTables() async {
    var db = await getDb();
    var results = await db.rawQuery('SELECT * from Words');
    print('Words table');
    print('word   score   date  testDate  definition');
    for (Map<String, dynamic> map in results) {
      var word = map['word'];
      var score = map['score'];
      var dt = DateTime.fromMillisecondsSinceEpoch(map['date']);
      var testDate = 'no test date';
      if (map['testDate'] != null) {
        testDate = DateTime.fromMillisecondsSinceEpoch(map['testDate']).toString();
      }
      var definition = map['definition'];
      var short = definition == null ? 'no definition' : 'definition exists';
      print('$word $score $dt $testDate $short');
    }

    var translations = await db.rawQuery('SELECT * from Translations');
    print('Translations table');
    print('word   lang   translated');
    for (Map<String, dynamic> map in translations) {
      var word = map['word'];
      var lang = map['lang'];
      var translated = map['translated'];
      print('$word $lang $translated');
    }

  }
}

class WordInfo {
  String word;
  int score;
  FeedbackScore currentFeedback;

  WordInfo({this.word, this.score});

  WordInfo.fromMap(Map<String, dynamic> map) {
    word = map['word'];
    score = map['score'];
    var dt = DateTime.fromMillisecondsSinceEpoch(map['date']);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      "word" : word,
      "score" : score,
      "date" : DateTime.now().millisecondsSinceEpoch,
    };
    return map;
  }

  void scoreFeedback(FeedbackScore feedbackScore) {
    currentFeedback = feedbackScore;
  }

  void recordFeedback() {
    bool update = false;
    if (currentFeedback == FeedbackScore.Yes) {
      score = min(score+1, 5);
      update = true;
    }
    if (currentFeedback == FeedbackScore.No) {
      score = max(score-1, 0);
      update = true;
    }
    currentFeedback = FeedbackScore.Unspecified;

    if (update) {
      DbHelper().updateScore(word, score);
    }
  }
}


class LexicalDefinition {
  String word;
  String category;
  List<String> definitions;
  String pronunciationUrl;
  String pronunciationSpelling;

  LexicalDefinition({this.word, this.category, this.definitions,
    this.pronunciationUrl, this.pronunciationSpelling });
}

class WordDefinition {
  String word;
  String json;
  String translation;
  List<LexicalDefinition> entries;

  WordDefinition({this.word, this.entries });

  factory WordDefinition.fromJson(String word, String json) {
    if (json == null) {
      return WordDefinition(
        word: word,
        entries: null,
      );
    }

    const JsonDecoder decoder = const JsonDecoder();
    Map decoded = decoder.convert(json);
    List<LexicalDefinition> entries = List<LexicalDefinition>();

    try {
      for (Map lexicalEntry in decoded['results'][0]['lexicalEntries']) {

        List<String> definitions = new List<String>();
        String pronunciationUrl;
        String pronunciationSpelling;
        String category = lexicalEntry['lexicalCategory'];
        var pronunciations = lexicalEntry['pronunciations'];

        Map entry = lexicalEntry['entries'][0];

        pronunciations = pronunciations == null ? entry['pronunciations'] : pronunciations;
        if (pronunciations != null) {
          for (Map pronunciation in pronunciations) {
            pronunciationUrl = pronunciation['audioFile'];
            pronunciationSpelling =  pronunciation['phoneticSpelling'];
            if (pronunciationUrl != null && pronunciationSpelling != null) {
              break;
            }
          }
        }
        // skip pronounciation if already exists
        for (LexicalDefinition ent in entries) {
          if (pronunciationUrl == ent.pronunciationUrl && pronunciationSpelling == ent.pronunciationSpelling) {
            pronunciationUrl = null;
            pronunciationSpelling = null;
          }
        }

        for (Map sense in entry['senses']) {
          String definition = sense['definitions'][0];
          if (definition != null) {
            definitions.add(definition);
          }
        }

        entries.add(LexicalDefinition(
          word: word,
          category: category,
          definitions: definitions,
          pronunciationUrl: pronunciationUrl,
          pronunciationSpelling:pronunciationSpelling,
        ));
      }
    } catch (e) {
      print('fromJson error $e');
    }
    return WordDefinition(
      word: word,
      entries: entries,
    );
  }
}

class WordData {

  static String getUrl(String word) {
    return 'https://od-api.oxforddictionaries.com:443/api/v1/entries/en/$word/definitions%3Bpronunciations';
  }

  static Map<String,String> getHeaders() {
    Map<String,String> headers = <String,String>{};
    headers['Accept'] = 'application/json';
    headers['app_id'] = 'af8ed21c';
    headers['app_key'] = '49d21059c113d7e37c83b946ec46c148';
    return headers;
  }

  static Future<WordDefinition> fetchDefinition(String word) async {
    print('fetchDefinition for $word');
    WordDefinition definition = await DbHelper().getDefinition(word);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lang = (prefs.getString(Globals.PreferenceTranslateToLang) ?? Globals.noTranslation);
    if (lang != null && lang != Globals.noTranslation) {
      print('getting translation $lang');
      definition.translation = await DbHelper().getTranslated(word, lang);
    }
    print('returning from fetchDefinition');
    return definition;
  }

}