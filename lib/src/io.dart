import 'dart:convert';
import 'dart:io';

import 'package:novel_formatter/novel_formatter.dart';
import 'package:novel_formatter/src/utils.dart';

/// 文本输入。
/// 用于将小说文本通过[traverse]逐行导入。
/// 三个方法的异常均会被捕获，因此在出现问题时请抛出异常。
abstract class AbstractInput {
  /// 遍历所有输入文本，依次使用[outputFormatted]格式化并输出。
  Future<void> traverse(void Function(String text) outputFormatted);

  /// 在[traverse]方法之前执行，用于初始化输入的某些配置。
  ///
  /// 如果初始化时产生异常导致后续遍历失效，请在此处抛出异常。抛出的异常将被[FormatProcessor.format]截获。
  Future<void> initialize();

  /// 输入输出结束，销毁资源。
  Future<void> destroy();
}

class FileInput extends AbstractInput {
  final File file;
  final Encoding encoding;

  FileInput(this.file, this.encoding);

  @override
  Future<void> traverse(void Function(String text) outputFormatted) async {
    Stream<List<int>> inputStream = file.openRead().handleError((error) {
      throw error;
    });
    Stream<String> lines = encoding.decoder
        .bind(inputStream)
        .transform(const LineSplitter());
    await lines.forEach(outputFormatted);
  }

  @override
  Future<void> initialize() async {
    if (!file.existsSync()) {
      throw FileSystemException('FileNotFound');
    }
  }

  @override
  Future<void> destroy() async {}
}

/// 文本输出。
/// 可以将格式化完成的[String]字符串通过[output]方法输出到所需的地方。
/// 三个方法的异常均会被捕获，因此在出现问题时请抛出异常。
abstract class AbstractOutput {
  /// 输出格式化完成的文本[text]。
  Future<void> output(String text);

  /// 在[output]方法之前执行，用于初始化输出的某些配置项。
  ///
  /// 如果初始化时产生异常导致后续输出失效，请在此处抛出异常。抛出的异常将被[FormatProcessor.format]截获。
  Future<void> initialize();

  /// 导入导出结束，销毁资源。
  Future<void> destroy();
}

class FileOutput extends AbstractOutput {
  final File file;
  late final IOSink sink;

  FileOutput(this.file);

  @override
  Future<void> output(String text) async {
    sink.write(text);
  }

  @override
  Future<void> initialize() async {
    if (file.existsSync()) {
      FileUtil.clear(file);
    } else {
      file.createSync(recursive: true);
    }
    sink = file.openWrite(mode: FileMode.append);
  }

  @override
  Future<void> destroy() async {
    sink.close();
  }
}
