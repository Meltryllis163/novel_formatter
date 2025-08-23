import 'package:chinese_number/chinese_number.dart';

import '../novel_formatter.dart';
import 'utils.dart';

/// 源小说配置项。
class SourceOptions {
  /// [hasBrief] 默认值。
  static const bool defaultHasBrief = false;

  /// 小说读取器。
  final AbstractNovelReader reader;

  /// 是否有「简介」。
  final bool hasBrief;

  /// 「卷」导入配置项。
  final TitleSource volumeSource;

  /// 「章节」导入配置项。
  final TitleSource chapterSource;

  /// 「段落」导入配置项。
  final ParagraphSource paragraphSource;

  SourceOptions(
    this.reader, {
    this.volumeSource = const TitleSource(),
    this.chapterSource = const TitleSource(),
    this.paragraphSource = const ParagraphSource(),
    this.hasBrief = defaultHasBrief,
  });
}

/// 标题导入配置项。
class TitleSource {
  /// [maxLength] 默认值。
  static const int defaultMaxLength = 15;

  /// 标题的最大长度，超出该长度的字符串不会被判定为标题。
  final int maxLength;

  /// [regexes] 默认值。
  static const List<RegExp> defaultRegexes = [];

  /// 判断标题的正则表达式列表。
  /// 默认值：[]。
  final List<RegExp> regexes;

  const TitleSource({
    this.regexes = defaultRegexes,
    this.maxLength = defaultMaxLength,
  });
}

class ParagraphSource {
  /// [resegment] 默认值。
  static const bool defaultResegment = false;

  /// 是否重新分段。
  final bool resegment;

  /// [maxLength] 默认值。
  static const defaultMaxLength = 500;

  /// 段落最大长度，超出该长度的文本将不会再重新分段，而是作为完整段落输出。
  final int maxLength;

  const ParagraphSource({
    this.resegment = defaultResegment,
    this.maxLength = defaultMaxLength,
  });
}

/// 小说导出配置项。
class ExportOptions {
  /// 文本输出。
  final AbstractNovelWriter writer;

  /// 「简介」缩进格式。
  final Indentation? briefIndentation;

  /// 「卷」导出格式。
  final TitleExport volumeExport;

  /// 「章节」导出格式。
  final TitleExport chapterExport;

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

  const ExportOptions(this.writer, {
    this.briefIndentation,
    this.volumeExport = const TitleExport(),
    this.chapterExport = const TitleExport(),
    this.paragraphIndentation = defaultParagraphIndentation,
    this.blankLineCount = defaultBlankLineCount,
    this.replacements = defaultReplacements,
  });
}

class TitleExport {
  final TitleTemplate? template;
  final Indentation? indentation;

  const TitleExport({this.template, this.indentation});
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
}
