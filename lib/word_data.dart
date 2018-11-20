import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:sqflite/sqflite.dart';


enum FeedbackScore {Unspecified, Yes, No}

class WordInfo{
  String word;
  int score;
  FeedbackScore currentFeedback;

  WordInfo({this.word, this.score});

  WordInfo.fromMap(Map<String, dynamic> map) {
    word = map['word'];
    score = map['score'];
    var dt = DateTime.fromMillisecondsSinceEpoch(map['date']);
    print('Datetime: $dt');
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
    if (currentFeedback == FeedbackScore.Yes) {
      score = min(score+1, 5);
    }
    if (currentFeedback == FeedbackScore.No) {
      score = max(score-1, 0);
    }
    currentFeedback = FeedbackScore.Unspecified;
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
    var db = await getDb();
    db.insert("Words", wordInfo.toMap());
  }

  Future<List<WordInfo>> getWordInfos() async {
    var _wordInfos = List<WordInfo>();

    var db = await getDb();
    var results = await db.query("words", columns: ["word", "score", "date"], orderBy: "score");
    for (Map<String, dynamic> map in results) {
      _wordInfos.add(WordInfo.fromMap(map));
    }
    print(_wordInfos);
    return _wordInfos;
  }

  Future<Database> getDb() async {
    if (_db == null) {
      await _lock.synchronized(() async {
        // Check again once entering the synchronized block
        if (_db == null) {
          _db = await openDatabase(path, version: 1,
            onCreate: (Database db, int version) async {
              await db.execute("CREATE TABLE Words (word TEXT PRIMARY KEY, score INTEGER, date INTEGER, definition TEXT)");
              await db.execute("CREATE TABLE Translations(word TEXT PRIMARY KEY, lang TEXT, translated TEXT)");
            },
          );
        }
      });
    }
    return _db;
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
    String translation = await fetchTranslation(word);
    print(translation);

    bool exists = await responseExists(word);
    print('exists? $exists');
    if (exists) {
      String response = await readResponse(word);
      var wordDefinition = WordDefinition.fromJson(word, response);
      wordDefinition.translation = translation;
      return wordDefinition;
    }
    String url = WordData.getUrl(word);
    final response = await http.get(url, headers: WordData.getHeaders());
    if (response.statusCode == 200) {
      writeResponse(word, response.body);
      var wordDefinition = WordDefinition.fromJson(word, response.body);
      wordDefinition.translation = translation;
      return wordDefinition;
    } else {
      var code = response.statusCode;
      throw Exception('Failed to load $word: $code');
    }
  }

  static Future<String> fetchTranslation(String word) async {
    // TODO to language
    /*
    const String url = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=ja";
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
    */
    return null;
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static void writeResponse(String word, String response) async {
    final path = await _localPath;
    File wordFile = File('$path/$word.txt');
    wordFile.writeAsString(response);
  }

  static Future<String> readResponse(String word) async {
    final path = await _localPath;
    File wordFile = File('$path/$word.txt');

    String response = await wordFile.readAsString();
    return response;
  }

  static Future<bool> responseExists(String word) async {
    final path = await _localPath;
    File wordFile = File('$path/$word.txt');
    print('word file: $wordFile');

    return wordFile.exists();
  }
}