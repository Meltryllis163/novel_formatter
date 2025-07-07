import 'dart:convert';
import 'dart:io';

import 'novel.dart';
import 'options.dart';
import 'parsers.dart';
import 'utils.dart';

/// 小说格式化处理器。
///
/// 此类负责小说的整个格式化流程，包括：读取、格式化、导出。
class FormatProcessor {
  /// 小说导入配置项。
  final ImportOptions importOptions;

  /// 小说导出配置项。
  final ExportOptions exportOptions;

  FormatProcessor(this.importOptions, this.exportOptions);

  late BlankLineParser blankLineParser;
  late TitleParser volumeParser;
  late TitleParser chapterParser;
  late TitleFormatter volumeFormatter;
  late TitleFormatter chapterFormatter;
  late ParagraphFormatter paragraphFormatter;

  /// 初始化解析器和格式化器。
  void initialize() {
    blankLineParser = BlankLineParser();
    volumeParser = TitleParser(importOptions.volumeImportOptions);
    chapterParser = TitleParser(importOptions.chapterImportOptions);
    volumeFormatter = TitleFormatter(
      exportOptions.volumeTemplate,
      indentation: exportOptions.volumeIndentation,
    );
    chapterFormatter = TitleFormatter(
      exportOptions.chapterTemplate,
      indentation: exportOptions.chapterIndentation,
    );
    paragraphFormatter = ParagraphFormatter(
      indentation: exportOptions.paragraphIndentation,
    );
  }

  /// 格式化小说。
  ///
  /// 返回值表示格式化的结果：[fileNotFound]、[formatSuccess]
  Future<FormatResult> format() async {
    FormatResult result = FormatResult();
    final File file = importOptions.file;
    if (!file.existsSync()) {
      result.setStatus = FormatResultStatus.fileNotFound;
      return result;
    }
    Stream<List<int>> inputStream = file.openRead();
    Stream<String> lines = importOptions.encoding.decoder
        .bind(inputStream)
        .transform(const LineSplitter());
    try {
      final File exportFile = exportOptions.file;
      // 新建或清空导出文档。
      if (exportFile.existsSync()) {
        FileUtil.clear(exportFile);
      } else {
        exportFile.createSync();
      }
      initialize();
      IOSink sink = exportFile.openWrite(mode: FileMode.append);
      await for (final String line in lines) {
        String text = line.trim();
        // 空行判断
        BlankLine? blankLine = blankLineParser.tryParse(text);
        if (blankLine != null) {
          continue;
        }
        Title? volume = volumeParser.tryParse(text);
        if (volume != null) {
          String formatVolume = volumeFormatter.format(volume);
          result.volumeCount++;
          sink.writeln(formatVolume);
          continue;
        }
        Title? chapter = chapterParser.tryParse(text);
        if (chapter != null) {
          String formattedChapter = chapterFormatter.format(chapter);
          result.chapterCount++;
          sink.writeln(formattedChapter);
          continue;
        }
        sink.writeln(paragraphFormatter.format(Paragraph(text)));
      }
      sink.close();
      result.setStatus = FormatResultStatus.success;
      return result;
    } catch (e) {
      result.setStatus = FormatResultStatus.fail;
      return result;
    }
  }
}

enum FormatResultStatus {
  /// 未定义，说明未开启格式化流程。
  undefined,

  /// 文件不存在，未读取到需要格式化的文件。
  fileNotFound,

  /// 格式化完成。
  success,

  /// 格式化失败。
  fail,
}

class FormatResult {
  FormatResultStatus status = FormatResultStatus.undefined;

  set setStatus(FormatResultStatus status) {
    this.status = status;
  }

  int volumeCount = 0;
  int chapterCount = 0;
}

abstract class AbstractNovelElementFormatter<T extends NovelElement> {
  final Indentation? indentation;

  AbstractNovelElementFormatter({this.indentation});

  String format(T input);

  String indent(String input) {
    if (indentation == null) {
      return input;
    }
    return '${StrUtil.repeat(indentation!.chars, indentation!.count - 1)}$input';
  }
}

class TitleFormatter extends AbstractNovelElementFormatter<Title> {
  final TitleTemplate? template;

  TitleFormatter(this.template, {required super.indentation});

  @override
  String format(Title title) {
    String templateText = template == null ? title.text : template!.fill(title);
    return indent(templateText);
  }
}

class ParagraphFormatter extends AbstractNovelElementFormatter<Paragraph> {
  ParagraphFormatter({super.indentation});

  @override
  String format(Paragraph input) {
    return indent(input.text);
  }
}