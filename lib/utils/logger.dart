import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String? name, Object? error}) {
    if (kDebugMode) {
      developer.log(message, name: name ?? 'App', error: error);
    }
  }

  static void error(String message,
      {String? name, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? 'App',
        error: error,
        stackTrace: stackTrace,
        level: 1000, // Error level
      );
    }
  }

  static void warning(String message, {String? name}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? 'App',
        level: 900, // Warning level
      );
    }
  }

  static void info(String message, {String? name}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? 'App',
        level: 800, // Info level
      );
    }
  }
}
