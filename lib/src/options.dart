import 'dart:math';

import 'package:chinese_number/chinese_number.dart';
import 'package:novel_formatter/novel_formatter.dart';

import 'utils.dart';

/// 小说导入配置项。
class ImportOptions {
  /// 小说读取器。
  final AbstractInput input;

  /// 是否有简介。
  final bool hasBrief;

  /// 卷导入配置项。
  final TitleImportOptions volumeImportOptions;

  /// 章节导入配置项。
  final TitleImportOptions chapterImportOptions;

  ImportOptions(
    this.input, {
    required this.volumeImportOptions,
    required this.chapterImportOptions,
    this.hasBrief = false,
  });

  @override
  String toString() {
    return 'ImportOptions{input: $input, volumeImportOptions: $volumeImportOptions, chapterImportOptions: $chapterImportOptions}';
  }
}

/// 标题导入配置项。
class TitleImportOptions {
  /// 标题的最大长度，超出该长度的字符串不会被判定为标题。
  final int maxLength;

  /// 判断标题的正则表达式列表。
  final List<RegExp> regexes;

  TitleImportOptions({required this.regexes, this.maxLength = 15});

  @override
  String toString() {
    return 'TitleImportOptions:{ maxLength: $maxLength, regexes: $regexes }';
  }
}

/// 小说导出配置项。
class ExportOptions {
  /// 小说导出器。
  final AbstractOutput output;

  /// 导出卷格式模板。
  final TitleTemplate? volumeTemplate;

  /// 导出章节格式模板。
  final TitleTemplate? chapterTemplate;

  /// 简介缩进格式。
  final Indentation? briefIndentation;

  /// 卷缩进格式。
  final Indentation? volumeIndentation;

  /// 章节缩进格式。
  final Indentation? chapterIndentation;

  /// 段落缩进格式。
  final Indentation? paragraphIndentation;

  /// 段落之间空行数量。
  final int blankLineCount;

  /// 文本替换列表。
  final List<Replacement> replacements;

  ExportOptions(
    this.output, {
    this.volumeTemplate,
    this.chapterTemplate,
    this.briefIndentation,
    this.volumeIndentation,
    this.chapterIndentation,
    this.paragraphIndentation,
    this.blankLineCount = 0,
    this.replacements = const [],
  });

  @override
  String toString() {
    return 'ExportOptions{output: $output, volumeTemplate: $volumeTemplate, chapterTemplate: $chapterTemplate, volumeIndentation: $volumeIndentation, chapterIndentation: $chapterIndentation, paragraphIndentation: $paragraphIndentation, replcements: $replacements}';
  }
}

/// 缩进。
///
/// 缩进字符串由[count]个[chars]组成。
class Indentation {
  /// 缩进字符。
  final String chars;

  /// 缩进字符数量。
  final int count;

  Indentation(int spaceCount, this.chars) : count = max(0, spaceCount);

  Indentation.defaultChineseIndentationOptions() : count = 2, chars = '\u3000';

  String applyTo(String input) {
    return '${StrUtil.repeat(chars, count - 1)}$input';
  }

  @override
  String toString() {
    return 'Indentation{chars: $chars, count: $count}';
  }
}

/// [Title]模板，用于规范导出时的标题格式。
/// 拥有[cnum]，[num]，[name]三种占位符。
///
/// 例如：当[template]为「第{cnum}章 {name}」时，导出样式为「第一千零二十四章 标题名」。
class TitleTemplate {
  /// 中文章节数字占位符。
  static const String cnum = '{cnum}';

  /// 阿拉伯数字章节数字占位符。
  static const String num = '{num}';

  /// 标题名占位符
  static const String name = '{name}';

  final String template;

  TitleTemplate(this.template);

  String fill(Title title) {
    return template
        .replaceAll(
          TitleTemplate.cnum,
          (title.number ?? 0).toSimplifiedChineseNumber(),
        )
        .replaceAll(TitleTemplate.num, title.number.toString())
        .replaceAll(TitleTemplate.name, title.name ?? StrUtil.empty);
  }

  @override
  String toString() {
    return 'TitleTemplate{template: $template}';
  }
}
