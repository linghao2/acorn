import 'package:flutter/material.dart';

// Key is the display language and value is the language code
class Globals {
  static Color darkYellow = Color(0xFFFFB20A);
  static Color medYellow = Color(0xFFFED33D);
  static Color paleYellow = Color(0xFFFFFAE2);
  static Color backgroundYellow = Color(0xFFFFF2B6);
  static Color background = Color(0xFFF4F4F4);

  static String MixPanelToken = '5cd97a97d0c5047369b4839b275ec107';

  static String noTranslation = 'none';
  static var supportedTranslation = {
    noTranslation: 'None',
    'zh-Hans': 'Chinese Simplified',
    'zh-Hant': 'Chinese Traditional',
    'es':'Spanish',
    'fr': 'French',
    'hi': 'Hindi',
    'ja': 'Japanese',
    'pt': 'Portuguese',
    'ar': 'Arabic',
    'bn': 'Bangla',
    'ru': 'Russian',
    'de': 'German',
    'vi': 'Vietnamese',
  };

  // Preferences keys
  static String PreferenceTestWordCount = 'TestWordCount';
  static String PreferenceTranslateToLang = 'TranslateToLang';
}
