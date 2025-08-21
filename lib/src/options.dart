import 'package:chinese_number/chinese_number.dart';

import '../novel_formatter.dart';
import 'utils.dart';

/// 小说导入配置项。
class ImportOptions {
  /// [hasBrief] 默认值。
  static const bool defaultHasBrief = false;

  /// 小说读取器。
  final AbstractInput input;

  /// 是否有「简介」。
  final bool hasBrief;

  /// 「卷」导入配置项。
  final TitleImportOptions volumeImportOptions;

  /// 「章节」导入配置项。
  final TitleImportOptions chapterImportOptions;

  /// 「段落」导入配置项。
  final ParagraphImportOptions paragraphImportOptions;

  const ImportOptions(
    this.input, {
    this.volumeImportOptions = const TitleImportOptions(),
    this.chapterImportOptions = const TitleImportOptions(),
    this.paragraphImportOptions = const ParagraphImportOptions(),
    this.hasBrief = defaultHasBrief,
  });

  @override
  String toString() {
    return 'ImportOptions{input: $input, hasBrief: $hasBrief, volumeImportOptions: $volumeImportOptions, chapterImportOptions: $chapterImportOptions, paragraphImportOptions: $paragraphImportOptions}';
  }
}

/// 标题导入配置项。
class TitleImportOptions {
  /// [maxLength] 默认值。
  static const int defaultMaxLength = 15;

  /// 标题的最大长度，超出该长度的字符串不会被判定为标题。
  final int maxLength;

  /// [regexes] 默认值。
  static const List<RegExp> defaultRegexes = [];

  /// 判断标题的正则表达式列表。
  /// 默认值：[]。
  final List<RegExp> regexes;

  const TitleImportOptions({
    this.regexes = defaultRegexes,
    this.maxLength = defaultMaxLength,
  });

  @override
  String toString() {
    return 'TitleImportOptions:{ maxLength: $maxLength, regexes: $regexes }';
  }
}

class ParagraphImportOptions {
  /// [resegment] 默认值。
  static const bool defaultResegment = false;

  /// 是否重新分段。
  final bool resegment;

  /// [maxLength] 默认值。
  static const defaultMaxLength = 500;

  /// 段落最大长度，超出该长度的文本将不会再重新分段，而是作为完整段落输出。
  final int maxLength;

  const ParagraphImportOptions({
    this.resegment = defaultResegment,
    this.maxLength = defaultMaxLength,
  });
}

/// 小说导出配置项。
class ExportOptions {
  /// 文本输出。
  final AbstractOutput output;

  /// 「简介」缩进格式。
  final Indentation? briefIndentation;

  /// 「卷」导出格式。
  final TitleExportOptions volumeExportOptions;

  /// 「章节」导出格式。
  final TitleExportOptions chapterExportOptions;

  static const Indentation defaultParagraphIndentation =
      Indentation.defaultChineseIndentation();

  /// 「段落」缩进格式。
  final Indentation? paragraphIndentation;

  /// [blankLineCount] 默认值。
  static const int defaultBlankLineCount = 0;

  /// 段落之间空行数量。
  final int blankLineCount;

  /// [replacements] 默认值。
  static const List<Replacement> defaultReplacements = [];

  /// 文本替换列表。
  final List<Replacement> replacements;

  const ExportOptions(
    this.output, {
    this.briefIndentation,
    this.volumeExportOptions = const TitleExportOptions(),
    this.chapterExportOptions = const TitleExportOptions(),
    this.paragraphIndentation = defaultParagraphIndentation,
    this.blankLineCount = defaultBlankLineCount,
    this.replacements = defaultReplacements,
  });
}

class TitleExportOptions {
  final TitleTemplate? template;
  final Indentation? indentation;

  const TitleExportOptions({this.template, this.indentation});

  @override
  String toString() {
    return 'TitleExportOptions{template: $template, indentation: $indentation}';
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

  const Indentation(this.count, this.chars);

  const Indentation.defaultChineseIndentation() : count = 2, chars = '\u3000';

  String applyTo(String input) {
    return chars * count + input;
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

  const TitleTemplate(this.template);

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
