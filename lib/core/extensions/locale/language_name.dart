import 'package:flutter/material.dart';

extension LanguageName on Locale {
  String get name => _mapLocales[languageCode] ?? languageCode;
}

Map<String, String> _mapLocales = {
  'en': 'English',
  'ar': 'العربية',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',
  'hi': 'हिंदी',
  'id': 'Bahasa Indonesia',
  'it': 'Italiano',
  'ja': '日本語',
  'ko': '한국어',
  'nl': 'Nederlands',
  'pl': 'Polski',
  'pt': 'Português',
  'ru': 'Русский',
  'tr': 'Türkçe',
  'uk': 'Українська',
  'vi': 'Tiếng Việt',
  'zh': '简体中文',
  'zh-Hant': '繁體中文',
  'zh-Hans': '简体中文',
};
