import 'package:logger/logger.dart';

final logger = _MyLogger._consoleInstance;

/// 用于随处访问[logger]的类。
class _MyLogger extends Logger {
  _MyLogger._console() : super(printer: PrettyPrinter(methodCount: 1));
  static final _consoleInstance = _MyLogger._console();
}
