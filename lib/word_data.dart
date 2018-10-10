import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
            print('pronunciationUrl $pronunciationUrl');
            print('pronunciationSpelling $pronunciationSpelling');
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
    bool exists = await responseExists(word);
    if (exists) {
      String response = await readResponse(word);
      return WordDefinition.fromJson(word, response);
    }
    String url = WordData.getUrl(word);
    final response = await http.get(url, headers: WordData.getHeaders());
    if (response.statusCode == 200) {
      writeResponse(word, response.body);
      return WordDefinition.fromJson(word, response.body);
    } else {
      var code = response.statusCode;
      throw Exception('Failed to load $word');
    }
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

    return wordFile.exists();
  }
}