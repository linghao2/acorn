import 'dart:async';
import 'dart:convert';
import 'dart:io';
//import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class WordDefinition {
  String word;
  String category;
  List<String> definitions;
  String pronunciationUrl;

  String json;

  WordDefinition({this.word, this.category, this.definitions, this.pronunciationUrl});

  factory WordDefinition.fromJson(String word, String json) {
    const JsonDecoder decoder = const JsonDecoder();
    Map decoded = decoder.convert(json);
    Map lexicalEntry = decoded['results'][0]['lexicalEntries'][0];
    String category = lexicalEntry['lexicalCategory'];
    Map pronunciation = lexicalEntry['pronunciations'][0];
    String pronunciationUrl = pronunciation['audioFile'];
    Map entry = lexicalEntry['entries'][0];
    List<String> definitions = new List<String>();
    for (Map sense in entry['senses']) {
      String definition = sense['definitions'][0];
      if (definition != null) {
        definitions.add(definition);
      }
    }
    return WordDefinition(
      word: word,
      category: category,
      definitions: definitions,
      pronunciationUrl: pronunciationUrl,
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
    print('wordFile: $wordFile');

    return wordFile.exists();
  }
}