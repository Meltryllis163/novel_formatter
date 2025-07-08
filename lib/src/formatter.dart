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
  late VolumeFormatter volumeFormatter;
  late ChapterFormatter chapterFormatter;
  late ParagraphFormatter paragraphFormatter;

  /// 初始化解析器和格式化器。
  void initialize() {
    blankLineParser = BlankLineParser();
    volumeParser = TitleParser(importOptions.volumeImportOptions);
    chapterParser = TitleParser(importOptions.chapterImportOptions);

    volumeFormatter = VolumeFormatter(
      template: exportOptions.volumeTemplate,
      indentation: exportOptions.volumeIndentation,
      replacements: exportOptions.replcements,
    );
    chapterFormatter = ChapterFormatter(
      template: exportOptions.chapterTemplate,
      indentation: exportOptions.chapterIndentation,
      replacements: exportOptions.replcements,
    );
    paragraphFormatter = ParagraphFormatter(
      indentation: exportOptions.paragraphIndentation,
      replacements: exportOptions.replcements,
    );
  }

  /// 格式化小说。
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
        // 卷判断与格式化
        Title? volume = volumeParser.tryParse(text);
        if (volume != null) {
          String formatVolume = volumeFormatter.format(volume);
          result.volumeCount++;
          sink.writeln(formatVolume);
          continue;
        }
        // 章节判断与格式化
        Title? chapter = chapterParser.tryParse(text);
        if (chapter != null) {
          String formattedChapter = chapterFormatter.format(chapter);
          result.chapterCount++;
          sink.writeln(formattedChapter);
          continue;
        }
        // 段落格式化
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
  final List<Replacement> replacements;

  AbstractNovelElementFormatter({
    this.indentation,
    this.replacements = const [],
  });

  /// 根据不同格式器的规则，各自解析[T]来获取用于后续通用格式化流程的文本。
  String resolveText(T element);

  /// 格式化当前[NovelElement]文本。
  String format(T element) {
    String text = resolveText(element);
    String replaced = replace(text);
    return indent(replaced);
  }

  /// 判断当前格式器是否允许[replacement]替换规则。
  bool acceptReplacement(Replacement replacement);

  /// 对[input]字符串应用[replacements]替换规则。
  String replace(String input) {
    String replaced = input;
    for (Replacement r in replacements) {
      if (acceptReplacement(r)) {
        replaced = r.applyTo(replaced);
      }
    }
    return replaced;
  }

  /// 对[input]字符串添加[indentation]缩进。
  /// 当[indentation]为`null`时返回原字符串。
  String indent(String input) {
    if (indentation == null) {
      return input;
    }
    return '${StrUtil.repeat(indentation!.chars, indentation!.count - 1)}$input';
  }
}

abstract class AbstractTitleFormatter
    extends AbstractNovelElementFormatter<Title> {
  final TitleTemplate? template;

  AbstractTitleFormatter({
    required this.template,
    super.indentation,
    super.replacements,
  });

  @override
  String resolveText(Title title) {
    if (template == null) {
      return title.text;
    }
    return template!.fill(title);
  }
}

class VolumeFormatter extends AbstractTitleFormatter {
  VolumeFormatter({
    required super.template,
    super.indentation,
    super.replacements,
  });

  @override
  bool acceptReplacement(Replacement replacement) {
    return replacement.applyToVolume;
  }
}

class ChapterFormatter extends AbstractTitleFormatter {
  ChapterFormatter({
    required super.template,
    super.indentation,
    super.replacements,
  });

  @override
  bool acceptReplacement(Replacement replacement) {
    return replacement.applyToVolume;
  }
}

class ParagraphFormatter extends AbstractNovelElementFormatter<Paragraph> {
  ParagraphFormatter({super.indentation, super.replacements});

  @override
  bool acceptReplacement(Replacement replacement) {
    return replacement.applyToParagraph;
  }

  @override
  String resolveText(Paragraph paragraph) {
    return paragraph.text;
  }
}

/// 替换规则，用于小说文本的批量替换。
class Replacement {
  final String from;
  final String to;

  /// [from]是否为正则字符串。
  final bool isRegExp;

  /// 是否对卷有效。
  final bool applyToVolume;

  /// 是否对章节有效。
  final bool applyToChapter;

  /// 是否对段落有效。
  final bool applyToParagraph;

  Replacement(
    this.isRegExp,
    this.from,
    this.to, {
    this.applyToVolume = true,
    this.applyToChapter = true,
    this.applyToParagraph = true,
  });

  /// 将当前替换规则应用到[input]。
  String applyTo(String input) {
    return input.replaceAll(isRegExp ? RegExp(from) : from, to);
  }
}
