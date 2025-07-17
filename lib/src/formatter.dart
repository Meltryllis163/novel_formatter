import 'dart:io';

import 'package:novel_formatter/novel_formatter.dart';

import 'logger.dart';

/// 小说格式化处理器。
///
/// 此类负责小说的整个格式化流程，包括：读取、格式化、导出。
class FormatProcessor {
  /// 小说导入配置项。
  final ImportOptions importOptions;

  /// 小说导出配置项。
  final ExportOptions exportOptions;

  FormatProcessor(this.importOptions, this.exportOptions);

  late AbstractInput input;
  late AbstractOutput output;
  late BlankLineParser blankLineParser;
  late TitleParser volumeParser;
  late TitleParser chapterParser;

  late BriefFormatter briefFormatter;
  late VolumeFormatter volumeFormatter;
  late ChapterFormatter chapterFormatter;
  late ParagraphFormatter paragraphFormatter;

  /// 初始化解析器和格式化器。
  void initialize() {
    input = importOptions.input;
    output = exportOptions.output;

    blankLineParser = BlankLineParser();
    volumeParser = TitleParser(importOptions.volumeImportOptions);
    chapterParser = TitleParser(importOptions.chapterImportOptions);

    briefFormatter = BriefFormatter(
      indentation: exportOptions.briefIndentation,
      replacements: exportOptions.replacements,
    );
    volumeFormatter = VolumeFormatter(
      template: exportOptions.volumeTemplate,
      indentation: exportOptions.volumeIndentation,
      replacements: exportOptions.replacements,
    );
    chapterFormatter = ChapterFormatter(
      template: exportOptions.chapterTemplate,
      indentation: exportOptions.chapterIndentation,
      replacements: exportOptions.replacements,
    );
    paragraphFormatter = ParagraphFormatter(
      indentation: exportOptions.paragraphIndentation,
      replacements: exportOptions.replacements,
    );
  }

  /// 格式化小说。
  Future<FormatResult> format() async {
    FormatResult result = FormatResult();
    initialize();
    try {
      input.initialize();
      output.initialize();
      Stream<String> lines = input.stream;
      await for (String line in lines) {
        String text = line.trim();
        if (blankLineParser.tryParse(text) != null) {
          continue;
        }
        Title? volume, chapter;
        String formatText = text;
        // 解析与格式化
        if ((volume = volumeParser.tryParse(text)) != null) {
          formatText = volumeFormatter.format(volume!);
          result.volumeCount++;
        } else if ((chapter = chapterParser.tryParse(text)) != null) {
          formatText = chapterFormatter.format(chapter!);
          result.chapterCount++;
        } else if (importOptions.hasBrief &&
            result.volumeCount == 0 &&
            result.chapterCount == 0) {
          // 如果当前文本既不是卷也不是行
          // 而且：当前小说有简介 && 当前未检测到卷 && 当前未检测到章节
          // 则认为当前文本为简介
          formatText = briefFormatter.format(Brief(text));
        } else {
          formatText = paragraphFormatter.format(Paragraph(text));
        }
        // 输出格式化文本。
        output.output(formatText + Platform.lineTerminator);
        // 输出空行。
        for (int i = 0; i < exportOptions.blankLineCount; i++) {
          output.output(Platform.lineTerminator);
        }
      }
      ;
      input.destroy();
      output.destroy();
      logger.i('Format success.');
      return result;
    } catch (e) {
      logger.d('Format failed. Exception: $e');
      result.fail(e);
      return result;
    }
  }
}

class FormatResult {
  late bool success = true;
  late Object? exception;

  void fail(Object e) {
    success = false;
    exception = e;
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
    return indentation == null ? input : indentation!.applyTo(input);
  }
}

abstract class AbstractTitleFormatter
    extends AbstractNovelElementFormatter<Title> {
  /// 标题模板。
  final TitleTemplate? template;

  AbstractTitleFormatter({
    this.template,
    super.indentation,
    super.replacements,
  });

  /// 使用[template]模板解析[Title]标题。
  /// 如果[template]为`null`则直接返回标题文本。
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

class BriefFormatter extends AbstractNovelElementFormatter<Brief> {
  BriefFormatter({super.indentation, super.replacements});

  @override
  bool acceptReplacement(Replacement replacement) {
    return replacement.applyToBrief;
  }

  @override
  String resolveText(Brief element) {
    return element.text;
  }
}

/// 替换规则，用于小说文本的批量替换。
class Replacement {
  final String from;
  final String to;

  /// [from]是否为正则字符串。
  final bool isRegExp;

  /// 是否对简介有效。
  final bool applyToBrief;

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
    this.applyToBrief = true,
    this.applyToVolume = true,
    this.applyToChapter = true,
    this.applyToParagraph = true,
  });

  /// 将当前替换规则应用到[input]。
  String applyTo(String input) {
    return input.replaceAll(isRegExp ? RegExp(from) : from, to);
  }
}
