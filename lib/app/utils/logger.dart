import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'MoBusiness';

  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      final buffer = StringBuffer('[$_tag] INFO: $message');
      if (data != null) buffer.write(' - $data');
      debugPrint(buffer.toString());
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    final buffer = StringBuffer('[$_tag] ERROR: $message');
    if (error != null) buffer.write(' - $error');
    debugPrint(buffer.toString());
    
    if (error != null && error is Error) {
      debugPrintStack(stackTrace: error.stackTrace, label: 'Error Stack Trace');
    } else if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace, label: 'Stack Trace');
    }
  }

  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      final buffer = StringBuffer('[$_tag] DEBUG: $message');
      if (data != null) buffer.write(' - $data');
      debugPrint(buffer.toString());
    }
  }

  static void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      final buffer = StringBuffer('[$_tag] WARNING: $message');
      if (data != null) buffer.write(' - $data');
      debugPrint(buffer.toString());
    }
  }
}
