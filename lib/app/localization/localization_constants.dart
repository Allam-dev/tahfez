import 'locales.dart';

abstract interface class LocalizationConstants {
  static const assetsPath = 'assets/translation';
  static const supportedLocales = [AppLocales.english, AppLocales.arabic];
  static const defaultLocale = AppLocales.arabic;
  static const fallbackLocale = AppLocales.arabic;
}
