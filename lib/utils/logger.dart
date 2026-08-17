import 'package:flutter/foundation.dart';

class Logger {
  static final List<String> _logs = [];

  static List<String> get logs => List.unmodifiable(_logs);

  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final formattedMessage = '[$timestamp] $message';
    _logs.add(formattedMessage);
    if (kDebugMode) {
      print(formattedMessage);
    }
  }

  static void clear() {
    _logs.clear();
  }
}
