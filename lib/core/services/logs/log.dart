import 'package:logger/logger.dart';

abstract class Log {
  static final Logger _logger = Logger();

  static void debug(String message) {
    _logger.d(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void error(String message) {
    _logger.e(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }
}
