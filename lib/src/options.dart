import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chinese_number/chinese_number.dart';

import 'novel.dart';
import 'utils.dart';

/// 小说导入配置项。
class ImportOptions {
  /// 小说文件。
  final File file;

  /// 小说编码，默认为[utf8]。
  final Encoding encoding;

  /// 卷导入配置项。
  final TitleImportOptions volumeImportOptions;

  /// 章节导入配置项。
  final TitleImportOptions chapterImportOptions;

  ImportOptions(
    String filePath, {
    required this.volumeImportOptions,
    required this.chapterImportOptions,
    this.encoding = utf8,
  }) : file = File(filePath);
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
  /// 导出小说位置。
  final File file;

  /// 导出小说编码。
  final Encoding encoding;
  /// 导出卷格式模板。
  final TitleTemplate? volumeTemplate;
  /// 导出章节格式模板。
  final TitleTemplate? chapterTemplate;
  /// 卷缩进格式。
  final Indentation? volumeIndentation;
  /// 章节缩进格式。
  final Indentation? chapterIndentation;
  /// 段落缩进格式。
  final Indentation? paragraphIndentation;

  ExportOptions(
    String filePath, {
    this.volumeTemplate,
    this.chapterTemplate,
    this.volumeIndentation,
    this.chapterIndentation,
    this.paragraphIndentation,
    this.encoding = utf8,
  }) : file = File(filePath);

  @override
  String toString() {
    return 'ExportOptions: { $encoding, volume$volumeTemplate, chapter$chapterTemplate, volumeIndentation: $volumeIndentation,'
        ' chapterIndentation: $chapterIndentation, paragraphIndentation: $paragraphIndentation }';
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

  @override
  String toString() {
    return 'Indentation:{ count: $count, chars: "$chars" }';
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
          (title.num ?? 0).toSimplifiedChineseNumber(),
        )
        .replaceAll(TitleTemplate.num, title.num.toString())
        .replaceAll(TitleTemplate.name, title.name ?? StrUtil.empty);
  }

  @override
  String toString() {
    return 'TitleTemplate:{ "$template" }';
  }
}
