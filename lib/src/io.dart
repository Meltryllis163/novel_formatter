import 'dart:convert';
import 'dart:io';

import 'package:novel_formatter/src/utils.dart';

/// 文本输入。
/// 将小说文本生成[stream]输入流，用于格式化与导出。
abstract class AbstractInput {
  /// 遍历所有输入文本，依次使用[outputFormatted]格式化并输出。
  Stream<String> get stream;

  /// 初始化。
  /// 该方法会在首次获取[stream]之前被调用。
  void initialize();

  /// 输入输出结束，销毁资源。
  void destroy();
}

class FileInput extends AbstractInput {
  final File file;
  final Encoding encoding;

  FileInput(this.file, this.encoding);

  @override
  Stream<String> get stream {
    Stream<List<int>> inputStream = file.openRead().handleError((error) {
      throw error;
    });
    return encoding.decoder.bind(inputStream).transform(const LineSplitter());
  }

  @override
  void initialize() {
    if (!file.existsSync()) {
      throw FileSystemException('FileNotFound');
    }
  }

  @override
  void destroy() {}
}

/// 文本输出。
/// 将字符串输出到指定位置。
abstract class AbstractOutput {
  /// 输出文本[text]。
  void output(String text);

  /// 初始化。
  /// 该方法会在首次[output]之前被调用。
  void initialize();

  /// 输入输出结束，销毁资源。
  void destroy();
}

/// 文件输出。
/// 将字符串输出到文件。
class FileOutput extends AbstractOutput {
  /// 输出文件位置。
  final File file;
  late final IOSink sink;

  FileOutput(this.file);

  @override
  void output(String text) {
    sink.write(text);
  }

  @override
  void initialize() {
    if (file.existsSync()) {
      FileUtil.clear(file);
    } else {
      file.createSync(recursive: true);
    }
    sink = file.openWrite(mode: FileMode.append);
  }

  @override
  void destroy() {
    sink.close();
  }
}
